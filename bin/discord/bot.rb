# Load rails framework
require_relative '../../config/environment'

# Load standard library
require 'open-uri'

# Load discord-recruitment-bot scripts
Dir['lib/discord/**/*.rb'].each {|file| require './' + file }

def inheritance
  if ARGV[0] == "nodaemon"
    Object
  else
    DaemonSpawn::Base
  end
end

class Bot < inheritance
  def start(args)
    %w(
      DISCORD_BOT_TOKEN
      DISCORD_BOT_CLIENT_ID
      DISCORD_BOT_RECRUITMENT_CHANNEL_ID
      DISCORD_BOT_TWITTER_CONSUMER_KEY
      DISCORD_BOT_TWITTER_CONSUMER_SECRET
      DISCORD_BOT_TWITTER_ACCESS_TOKEN
      DISCORD_BOT_TWITTER_ACCESS_TOKEN_SECRET
      DISCORD_BOT_TWITTER_NOTICE_TITLE
    ).each do |name|
      if ENV[name].blank?
        STDERR.puts "[ERROR] 必須の環境変数 #{name} が定義されていません。プログラムを終了します。"
        exit
      end
    end

    loop do
      self.sequence()
      STDERR.puts "[INFO] BOTを再起動して復旧を試みます。"
      sleep 60
    end
  end

  def sequence
    $bot = Discordrb::Commands::CommandBot.new ({
      token: ENV['DISCORD_BOT_TOKEN'],
      client_id: ENV['DISCORD_BOT_CLIENT_ID'],
      prefix:'/',
      # log_mode: :debug,
    })

    $bot.message do |event|
      if event.kind_of?(Discordrb::Events::MessageEvent)
        ActionSelector.get_message(event)
      end
    end

    $bot.run(true)

    $bot.servers.each do |server_id, server|
      server.channels.each do |channel|
        $recruitment_channel = channel if ENV['DISCORD_BOT_RECRUITMENT_CHANNEL_ID'] == channel.id.to_s
        $play_channel = channel if ENV['DISCORD_BOT_PLAY_CHANNEL_ID'] == channel.id.to_s
      end
    end

    puts "[INFO] 解析インターバル: #{AnalysisController::ANALYSIS_INTERVAL} (0なら無効)"

    if $recruitment_channel.present?
      puts "[INFO] 募集機能動作チャンネル: #{$recruitment_channel.name})"
    else
      STDERR.puts "[ERROR] 募集機能動作チャンネルがないので動作できません。"
      raise StandardError.new("Not found channel.")
    end

    puts "[INFO] 遊び機能動作チャンネル: #{$play_channel.present? ? $play_channel.name : "なし"}"
    puts "[INFO] Twitter連携機能: #{ENV['DISCORD_BOT_TWITTER_DISABLE'].present? ? "オフ" : "オン"}"

    loop do
      begin
        RecruitmentController.destroy_expired_recruitment
        AnalysisController.voice_channels
      rescue HTTP::ConnectionError => e
        STDERR.puts "[ERROR] サーバへのアクセスに失敗しました。"
      rescue Api::InvalidStatusError => e
        STDERR.puts "[ERROR] #{e.message}"
      end

      sleep 10
    end
  rescue => e
    STDERR.puts "[ERROR] #{e.message}"
    $bot.stop
  end

  def stop; end
end

if ARGV[0] == "nodaemon"
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
