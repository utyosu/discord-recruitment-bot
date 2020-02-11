BOT_DAEMONIZE = false unless defined?(BOT_DAEMONIZE)

class Bot < BOT_DAEMONIZE ? DaemonSpawn::Base : Object
  def start(_args)
    loop { sequence }
  end

  def sequence
    bot = Discordrb::Commands::CommandBot.new(
      token: Settings.secret.discord.token,
      client_id: Settings.secret.discord.client_id,
      prefix: "/",
      log_mode: Settings.bot.log_mode.to_sym,
    )

    action_selector = ActionSelector.new
    bot.message do |event|
      action_selector.execute(event) if event.is_a?(Discordrb::Events::MessageEvent)
    end

    bot.run(true)
    logging_startup(bot)
    timers = Timers::Group.new
    recruitment_base = RecruitmentBase.new
    recruitment_channel = Helper.get_channel(bot, Settings.secret.discord.recruitment_channel_id)
    analysis_controller = AnalysisController.new
    timers.every(1.minute) do
      recruitment_base.destroy_expired_recruitment(recruitment_channel)
      analysis_controller.voice_channels(bot)
    end
    loop { timers.wait }
  rescue StandardError => e
    logging_error(e)
    bot.stop
    sleep 60
  end

  def logging_startup(bot)
    logger = Logger.new(STDOUT)
    logger.info I18n.t("bot.analysis_interval", interval: AnalysisController::ANALYSIS_INTERVAL)

    recruitment_channel = Helper.get_channel(bot, Settings.secret.discord.recruitment_channel_id)
    logger.info I18n.t("bot.recruitment_channel", name: recruitment_channel.try(:name))

    play_channel = Helper.get_channel(bot, Settings.secret.discord.play_channel_id)
    logger.info I18n.t("bot.play_channel", name: play_channel.try(:name))
    logger.info I18n.t("bot.use_twitter", bool: TwitterController.new.ready?)
  end

  def logging_error(error)
    logger = Logger.new(STDOUT)
    logger.error I18n.t("bot.reboot")
    logger.error error.full_message
    Slack::Web::Client.new(token: Settings.secret.slack.access_token).chat_postMessage(
      channel: Settings.secret.slack.notify_channel,
      text: "[#{Rails.env}] #{I18n.t("bot.reboot")}\n```#{error.full_message(highlight: false)}```",
    )
  end

  def stop; end
end
