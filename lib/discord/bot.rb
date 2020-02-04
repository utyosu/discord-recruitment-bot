BOT_DAEMONIZE ||= false

class Bot < BOT_DAEMONIZE ? DaemonSpawn::Base : Object
  def start(args)
    loop do
      self.sequence()
    end
  end

  def sequence
    bot = Discordrb::Commands::CommandBot.new ({
      token: Settings.secret.discord.token,
      client_id: Settings.secret.discord.client_id,
      prefix:'/',
      # log_mode: :debug,
    })

    bot.message do |event|
      if event.kind_of?(Discordrb::Events::MessageEvent)
        ActionSelector.get_message(event, bot)
      end
    end

    bot.run(true)

    logger = Logger.new STDOUT
    logger.info I18n.t('bot.analysis_interval', interval: AnalysisController::ANALYSIS_INTERVAL)

    recruitment_channel = Helper.get_channel(bot, Settings.secret.discord.recruitment_channel_id)
    logger.info I18n.t('bot.recruitment_channel', name: recruitment_channel.try(:name))

    play_channel = Helper.get_channel(bot, Settings.secret.discord.play_channel_id)
    logger.info I18n.t('bot.play_channel', name: play_channel.try(:name))
    logger.info I18n.t('bot.use_twitter', bool: TwitterController.ready?)

    timers = Timers::Group.new
    timers.every(1.minute) do
      RecruitmentController.destroy_expired_recruitment(recruitment_channel)
      AnalysisController.voice_channels(bot)
    end
    loop { timers.wait }
  rescue => e
    STDERR.puts I18n.t('bot.reboot')
    STDERR.puts e.full_message
    Slack::Web::Client.new(token: Settings.secret.slack.access_token).chat_postMessage(
      channel: Settings.secret.slack.notify_channel,
      text: "[#{Rails.env}] #{I18n.t('bot.reboot')}\n```#{e.full_message(highlight: false)}```"
   )
   bot.stop
   sleep 60
  end

  def stop; end
end
