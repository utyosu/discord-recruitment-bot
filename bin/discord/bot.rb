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
      if ENV[name].nil?
        puts "必須の環境変数 #{name} が定義されていません。プログラムを終了します。"
        exit
      end
    end

    $recruitment_channel_ids = []
    if ENV['DISCORD_BOT_RECRUITMENT_CHANNEL_IDS'].nil?
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
    recruitments = Api::Recruitment.index
    return "```\n募集はありません\n```" if recruitments.empty?
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
    return true if $recruitment_channel_ids.empty?
    return $recruitment_channel_ids.include?(message_event.channel.id.to_s)
  end

  def match_keywords(message_event, keywords)
    to_safe(message_event.content) =~ /#{keywords.join("|")}/
  end

  def get_message(message_event)

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
      end
    end
  end

  def open(message_event)
    recruitment = Api::Recruitment.create(message_event.content, extraction_expired_time(message_event.content))
    Api::Participant.join(recruitment['id'], message_event.author)
    message_event.send_message("募集 [#{recruitment['label_id']}] を受け付けました。")
    message_event.send_message(recruitments_message)
  end

  def close(message_event)
    number = extraction_number(message_event.content)
    my_discord_id = message_event.author.id.to_s
    closed_indexes = []
    if 1 <= number
      Api::Recruitment.index.each do |recruitment, recruitment_index|
        if number == recruitment['label_id']
          Api::Recruitment.destroy(recruitment['id'])
          closed_indexes.push(recruitment['label_id'])
        end
      end
    else
      Api::Recruitment.index.each do |recruitment|
        next if recruitment['author_discord_id'] != my_discord_id
        Api::Recruitment.destroy(recruitment['id'])
        closed_indexes.push(recruitment['label_id'])
      end
    end
    if closed_indexes.empty?
      message_event.send_message("しめる募集がありません。")
    else
      message_event.send_message("#{closed_indexes.sort.map{|a|"[#{a}]"}.join} の募集を終了しました。")
      message_event.send_message(recruitments_message)
    end
  end

  def join(message_event)
    number = extraction_number(message_event.content)
    recruitments = Api::Recruitment.index
    joined_indexes = []
    if recruitments.size == 1
      Api::Participant.join(recruitments.first['id'], message_event.author)
      joined_indexes.push(recruitments.first['label_id'])
    elsif 2 <= recruitments.size && 1 <= number
      recruitments.each do |recruitment|
        if number == recruitment['label_id'] && !recruitment['participants'].any?{|p|p['discord_id'] == message_event.author.id.to_s}
          Api::Participant.join(recruitment['id'], message_event.author)
          joined_indexes.push(recruitment['label_id'])
        end
      end
    end
    if joined_indexes.empty?
      message_event.send_message("参加できませんでした。")
    else
      message_event.send_message("#{joined_indexes.sort.map{|a|"[#{a}]"}.join} に参加しました。")
      message_event.send_message(recruitments_message)
    end
  end

  def leave(message_event)
    number = extraction_number(message_event.content)
    my_discord_id = message_event.author.id.to_s
    leaved_indexes = []
    Api::Recruitment.index.each do |recruitment|
      recruitment['participants'].each do |participant|
        if participant['discord_id'] == my_discord_id && (number == 0 || number == recruitment['label_id'])
          Api::Participant.leave(recruitment['id'], participant['id'])
          leaved_indexes.push(recruitment['label_id'])
        end
      end
    end
    if leaved_indexes.empty?
      message_event.send_message("参加をキャンセルできませんでした。")
    else
      message_event.send_message("#{leaved_indexes.sort.map{|a|"[#{a}]"}.join} の参加をキャンセルしました。")
      message_event.send_message(recruitments_message)
    end
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
    :singleton => true # これを指定すると多重起動しない
  })
end
