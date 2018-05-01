require 'active_support'
require 'active_support/core_ext'
require 'discordrb'
require 'json'
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require_relative 'api'
require_relative 'lib'
require_relative 'keywords'

def inheritance
  if ARGV[0] == "nodaemon"
    Object
  else
    DaemonSpawn::Base
  end
end

class Bot < inheritance
  def start(args)
    ['DISCORD_BOT_TOKEN', 'DISCORD_BOT_CLIENT_ID'].each do |name|
      if ENV[name].blank?
        puts "必須の環境変数 #{name} が定義されていません。プログラムを終了します。"
        exit
      end
    end

    $recruitment_channel_ids = []
    if ENV['DISCORD_BOT_RECRUITMENT_CHANNEL_IDS'].blank?
      puts "環境変数 DISCORD_BOT_RECRUITMENT_CHANNEL_IDS が定義されていないので、全てのチャンネルで動作します。"
    else
      $recruitment_channel_ids = ENV['DISCORD_BOT_RECRUITMENT_CHANNEL_IDS'].split(",")
      puts "動作するチャンネル ID は #{$recruitment_channel_ids.join(", ")} です。"
    end

    $bot = Discordrb::Commands::CommandBot.new ({
      token: ENV['DISCORD_BOT_TOKEN'],
      client_id: ENV['DISCORD_BOT_CLIENT_ID'],
      prefix:'/',
      #log_mode: :debug,
    })

    $bot.message do |event|
      if event.kind_of?(Discordrb::Events::MessageEvent)
        get_message(event)
      end
    end

    $bot.run(true)

    while(true) do
      sleep 10
    end
  end

  def stop
  end

  def recruitments_message
    recruitments = JSON.parse(Api::Recruitment.index.body)
    return "```\n募集はありません\n```" if recruitments.blank?
    recruitment_message = ""
    recruitments.sort_by{|recruitment|
      recruitment['label_id']
    }.each{|recruitment|
      recruitment_message += "[#{recruitment['label_id']}] #{recruitment['content']} by #{recruitment['participants'].first['name']} (#{recruitment['participants'].size-1})\n"
      if 2 <= recruitment['participants'].size
        recruitment['participants'][1..-1].each do |participant|
          recruitment_message += "    - #{participant['name']}\n"
        end
      end
      recruitment_message += "\n"
    }
    return "```\n#{recruitment_message}\n```"
  end

  def check_executable(message_event)
    return true if $recruitment_channel_ids.blank?
    return $recruitment_channel_ids.include?(message_event.channel.id.to_s)
  end

  def match_keywords(message_event, keywords)
    to_safe(get_message_content(message_event)) =~ keywords
  end

  def get_message_content(message_event)
    message_event.content.split(/\r\n|\r|\n/).first
  end

  def get_message(message_event)
    begin
      if check_executable(message_event)
        if match_keywords(message_event, $KEYWORDS_START_RECRUITMENT)
          open(message_event)
        elsif match_keywords(message_event, $KEYWORDS_STOP_RECRUITMENT)
          close(message_event)
        elsif match_keywords(message_event, $KEYWORDS_JOIN_RECRUITMENT)
          join(message_event)
        elsif match_keywords(message_event, $KEYWORDS_LEAVE_RECRUITMENT)
          leave(message_event)
        elsif match_keywords(message_event, $KEYWORDS_SHOW_RECRUITMENT)
          message_event.send_message(recruitments_message)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_CREATE)
          interaction_create(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_DESTROY)
          interaction_destroy(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_RESPONSE)
          interaction_response(message_event)
        end
      end
    rescue HTTP::ConnectionError => e
      message_event.send_message("サーバへのアクセスに失敗しました。時間をおいても改善しない場合は管理者にご連絡下さい。")
    rescue Api::InvalidStatusError => e
      message_event.send_message(e.message)
    end
  end

  def open(message_event)
    recruitment = JSON.parse(Api::Recruitment.create(get_message_content(message_event), extraction_expired_time(get_message_content(message_event))).body)
    Api::Participant.join(recruitment['id'], message_event.author)
    message_event.send_message("募集 [#{recruitment['label_id']}] を受け付けました。")
    message_event.send_message(recruitments_message)
  end

  def close(message_event)
    number = extraction_number(get_message_content(message_event))
    my_discord_id = message_event.author.id.to_s
    closed_indexes = []
    if 1 <= number
      JSON.parse(Api::Recruitment.index.body).each do |recruitment, recruitment_index|
        if number == recruitment['label_id']
          Api::Recruitment.destroy(recruitment['id'])
          closed_indexes.push(recruitment['label_id'])
        end
      end
    end
    if closed_indexes.present?
      message_event.send_message("#{closed_indexes.sort.map{|a|"[#{a}]"}.join} の募集を終了しました。")
      message_event.send_message(recruitments_message)
    end
  end

  def join(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number < 1
    recruitments = JSON.parse(Api::Recruitment.index.body)
    joined_indexes = []
    recruitments.each do |recruitment|
      if number == recruitment['label_id'] && !recruitment['participants'].any?{|p|p['discord_id'] == message_event.author.id.to_s}
        Api::Participant.join(recruitment['id'], message_event.author)
        joined_indexes.push(recruitment['label_id'])
      end
    end
    if joined_indexes.present?
      message_event.send_message("#{joined_indexes.sort.map{|a|"[#{a}]"}.join} に参加しました。")
      message_event.send_message(recruitments_message)
    end
  end

  def leave(message_event)
    number = extraction_number(get_message_content(message_event))
    return if number < 1
    my_discord_id = message_event.author.id.to_s
    leaved_indexes = []
    JSON.parse(Api::Recruitment.index.body).each do |recruitment|
      next if number != recruitment['label_id']
      recruitment['participants'].each do |participant|
        if participant['discord_id'] == my_discord_id
          Api::Participant.leave(recruitment['id'], participant['id'])
          leaved_indexes.push(recruitment['label_id'])
        end
      end
    end
    if leaved_indexes.present?
      message_event.send_message("#{leaved_indexes.sort.map{|a|"[#{a}]"}.join} の参加をキャンセルしました。")
      message_event.send_message(recruitments_message)
    end
  end

  def interaction_create(message_event)
    src = get_message_content(message_event).gsub(/\p{blank}/," ").split
    return if src.size != 3 || src[1].size < 2 || src[2].size < 1 || 64 < src[1].size || 64 < src[2].size
    interaction = JSON.parse(Api::Interaction.create(src[1], src[2], message_event.author).body)
    message_event.send_message("「#{interaction['keyword']}」を「#{interaction['response']}」と覚えました。")
  end

  def interaction_destroy(message_event)
    src = get_message_content(message_event).gsub(/\p{blank}/," ").split
    return if src.size != 2 || src[1].size < 1
    response = Api::Interaction.destroy(src[1])
    message_event.send_message("「#{src[1]}」を忘れました。") if response.status == 200
  end

  def interaction_response(message_event)
    interaction = JSON.parse(Api::Interaction.search(get_message_content(message_event)).body)
    message_event.send_message(interaction['response']) if interaction['response'].present?
  end
end

if ARGV[0]=="nodaemon"
  bot = Bot.new
  bot.start ARGV
else
  Bot.spawn!({
    :working_dir => Rails.root,
    :pid_file => '/var/tmp/pids/discord_recruitment_bot_client.pid',
    :log_file => '/var/log/discord_recruitment_bot_client.log',
    :sync_log => true,
    :singleton => true,
  })
end
