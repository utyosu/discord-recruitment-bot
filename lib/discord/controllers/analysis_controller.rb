module AnalysisController
  module_function

  ANALYSIS_INTERVAL = Settings.analysis.interval_sec
  @last_updated = nil

  def voice_channels(bot)
    @last_updated = UserStatus.last&.created_at || Time.zone.now if @last_updated.blank?
    return if 0 < ANALYSIS_INTERVAL && (@last_updated + ANALYSIS_INTERVAL) > Time.zone.now
    @last_updated = Time.zone.now
    bot.servers.each do |_server_id, server|
      server.voice_channels.each do |discord_voice_channel|
        discord_voice_channel.users.each do |discord_user|
          user = User.get_by_discord_user(discord_user)
          channel = Channel.get_by_discord_channel(discord_voice_channel)
          UserStatus.create(user: user, channel: channel, interval: ANALYSIS_INTERVAL)
        end
      end
    end
  end
end
