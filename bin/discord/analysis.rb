module Analysis
  extend self

  ANALYSIS_INTERVAL = ENV['DISCORD_BOT_ANALYSIS_INTERVAL'].to_i
  @@last_checked = Time.zone.now

  def voice_channels
    return if 0 < ANALYSIS_INTERVAL && (@@last_checked + ANALYSIS_INTERVAL) > Time.zone.now
    @@last_checked = Time.zone.now
    $bot.servers.each do |server_id, server|
      server.voice_channels.each do |voice_channel|
        voice_channel.users.each do |user|
          Api::UserStatus.create(user_discord_id: user.id, user_name: user.username, channel_id: voice_channel.id, channel_name: voice_channel.name, interval: ANALYSIS_INTERVAL)
        end
      end
    end
  end
end
