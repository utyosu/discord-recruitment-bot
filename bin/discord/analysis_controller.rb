module AnalysisController
  extend self

  ANALYSIS_INTERVAL = ENV['DISCORD_BOT_ANALYSIS_INTERVAL'].to_i
  @@last_updated = nil

  def voice_channels
    if @@last_updated.blank?
      @@last_updated = JSON.parse(Api::UserStatus.last_updated.body)["updated_at"].in_time_zone rescue Time.zone_now
    end
    return if 0 < ANALYSIS_INTERVAL && (@@last_updated + ANALYSIS_INTERVAL) > Time.zone.now
    @@last_updated = Time.zone.now
    $bot.servers.each do |server_id, server|
      server.voice_channels.each do |voice_channel|
        voice_channel.users.each do |user|
          Api::UserStatus.create(user_discord_id: user.id, user_name: user.display_name, channel_id: voice_channel.id, channel_name: voice_channel.name, interval: ANALYSIS_INTERVAL)
        end
      end
    end
  end
end
