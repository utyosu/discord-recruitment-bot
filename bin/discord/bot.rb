require 'active_support'
require 'active_support/core_ext'
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require_relative 'api'
require_relative 'lib'
require_relative 'keywords'
require_relative 'recruitment_controller'
require_relative 'interaction_controller'
require_relative 'twitter_controller'
require_relative 'flickr'
require_relative 'analysis'

# 時間指定のない募集の期限 (秒)
EXPIRE_TIME = 60 * 60

def inheritance
  if ARGV[0] == "nodaemon"
    Object
  else
    DaemonSpawn::Base
  end
end

class Bot < inheritance
  def start(args)
    %w(DISCORD_BOT_TOKEN DISCORD_BOT_CLIENT_ID DISCORD_BOT_RECRUITMENT_CHANNEL_ID DISCORD_BOT_TWITTER_CONSUMER_KEY DISCORD_BOT_TWITTER_CONSUMER_SECRET DISCORD_BOT_TWITTER_ACCESS_TOKEN DISCORD_BOT_TWITTER_ACCESS_TOKEN_SECRET DISCORD_BOT_TWITTER_NOTICE_TITLE).each do |name|
      if ENV[name].blank?
        STDERR.puts "[ERROR] 必須の環境変数 #{name} が定義されていません。プログラムを終了します。"
        exit
      end
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

    $bot.servers.each do |server_id, server|
      server.channels.each do |channel|
        $recruitment_channel = channel if ENV['DISCORD_BOT_RECRUITMENT_CHANNEL_ID'] == channel.id.to_s
        $interaction_channel = channel if ENV['DISCORD_BOT_INTERACTION_CHANNEL_ID'] == channel.id.to_s
        $food_channel = channel if ENV['DISCORD_BOT_FOOD_CHANNEL_ID'] == channel.id.to_s
      end
    end
    puts "[INFO] 解析インターバル: #{Analysis::ANALYSIS_INTERVAL} (0なら無効)"

    if $recruitment_channel.present?
      puts "[INFO] 募集機能動作チャンネル: #{$recruitment_channel.name} (#{$recruitment_channel.id})"
    else
      STDERR.puts "[ERROR] 募集機能動作チャンネルがないので終了します。"
      exit
    end
    if $interaction_channel.present?
      puts "[INFO] 対話機能動作チャンネル: #{$interaction_channel.name} (#{$interaction_channel.id})"
    else
      puts "[INFO] 対話機能動作チャンネル: なし"
    end
    if $food_channel.present?
      puts "[INFO] 飯テロ機能動作チャンネル: #{$food_channel.name} (#{$food_channel.id})"
    else
      puts "[INFO] 飯テロ機能動作チャンネル: なし"
    end
    if ENV['DISCORD_BOT_TWITTER_DISABLE'].present?
      puts "[INFO] Twitter連携機能: オフ"
    end

    loop do
      begin
        RecruitmentController::destroy_expired_recruitment
        Analysis::voice_channels
      rescue HTTP::ConnectionError => e
        STDERR.puts "[ERROR] サーバへのアクセスに失敗しました。"
      rescue Api::InvalidStatusError => e
        STDERR.puts "[ERROR] #{e.message}"
      end
      sleep 10
    end
  end

  def stop; end

  def get_message(message_event)
    begin
      # text channel or private channel (Direct Message)
      if message_event.channel.type == 1 || $recruitment_channel == message_event.channel
        if match_keywords(message_event, $KEYWORDS_OPEN_RECRUITMENT)
          RecruitmentController::open(message_event)
        elsif match_keywords(message_event, $KEYWORDS_CLOSE_RECRUITMENT)
          RecruitmentController::close(message_event)
        elsif match_keywords(message_event, $KEYWORDS_JOIN_RECRUITMENT)
          RecruitmentController::join(message_event)
        elsif match_keywords(message_event, $KEYWORDS_LEAVE_RECRUITMENT)
          RecruitmentController::leave(message_event)
        elsif match_keywords(message_event, $KEYWORDS_SHOW_RECRUITMENT)
          RecruitmentController::show(message_event)
        end
      end

      if message_event.channel.type == 1 || $interaction_channel == message_event.channel
        if match_keywords(message_event, $KEYWORDS_INTERACTION_CREATE)
          InteractionController::interaction_create(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_DESTROY)
          InteractionController::interaction_destroy(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_RESPONSE)
          InteractionController::interaction_response(message_event)
        end
      end

      if message_event.channel.type == 1 || $food_channel == message_event.channel
        if match_keywords(message_event, $KEYWORDS_FOOD_RESPONSE)
          Flickr.put_food_image(message_event)
        end
      end

      # only text channel
      if message_event.channel.type == 1
        if message_event.content =~ /\A\/talk/
          send_message_command(message_event)
        end
      end

    rescue HTTP::ConnectionError => e
      message_event.send_message("サーバへのアクセスに失敗しました。時間をおいても改善しない場合は管理者にご連絡下さい。")
    rescue Api::InvalidStatusError => e
      message_event.send_message(e.message)
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
    :singleton => true,
  })
end
