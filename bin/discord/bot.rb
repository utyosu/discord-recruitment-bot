require 'active_support'
require 'active_support/core_ext'
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require_relative 'api'
require_relative 'lib'
require_relative 'keywords'
require_relative 'recruitment_controller'
require_relative 'interaction_controller'
require_relative 'twitter_controller'

def inheritance
  if ARGV[0] == "nodaemon"
    Object
  else
    DaemonSpawn::Base
  end
end

class Bot < inheritance
  def start(args)
    %w(DISCORD_BOT_TOKEN DISCORD_BOT_CLIENT_ID DISCORD_BOT_RECRUITMENT_CHANNEL_IDS TWITTER_CONSUMER_KEY TWITTER_CONSUMER_SECRET TWITTER_ACCESS_TOKEN TWITTER_ACCESS_TOKEN_SECRET TWITTER_NOTICE_TITLE).each do |name|
      if ENV[name].blank?
        STRDERR.puts "[ERROR] 必須の環境変数 #{name} が定義されていません。プログラムを終了します。"
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

    $target_channels = []
    $bot.servers.each do |server_id, server|
      server.channels.each do |channel|
        if ENV['DISCORD_BOT_RECRUITMENT_CHANNEL_IDS'].split(",").include?(channel.id.to_s)
          $target_channels.push(channel)
          puts "[INFO] 動作チャンネル '#{channel.name}' (#{channel.id})"
        end
      end
    end
    if $target_channels.blank?
      STDERR.puts "[ERROR] 動作チャンネルがないので終了します。"
      exit
    end

    loop do
      begin
        RecruitmentController::destroy_expired_recruitment
      rescue HTTP::ConnectionError => e
        STDERR.puts "[ERROR] サーバへのアクセスに失敗しました。"
      rescue Api::InvalidStatusError => e
        STDERR.puts "[ERROR] #{e.message}"
      end
      sleep 60
    end
  end

  def stop
  end

  def get_message(message_event)
    begin
      if check_executable(message_event)
        if match_keywords(message_event, $KEYWORDS_START_RECRUITMENT)
          RecruitmentController::open(message_event)
        elsif match_keywords(message_event, $KEYWORDS_STOP_RECRUITMENT)
          RecruitmentController::close(message_event)
        elsif match_keywords(message_event, $KEYWORDS_JOIN_RECRUITMENT)
          RecruitmentController::join(message_event)
        elsif match_keywords(message_event, $KEYWORDS_LEAVE_RECRUITMENT)
          RecruitmentController::leave(message_event)
        elsif match_keywords(message_event, $KEYWORDS_SHOW_RECRUITMENT)
          RecruitmentController::show(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_CREATE)
          InteractionController::interaction_create(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_DESTROY)
          InteractionController::interaction_destroy(message_event)
        elsif match_keywords(message_event, $KEYWORDS_INTERACTION_RESPONSE)
          InteractionController::interaction_response(message_event)
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
