class Channel < ApplicationRecord
  def self.get_by_discord_channel(discord_channel)
    channel = Channel.find_or_initialize_by(channel_id: discord_channel.id)
    channel.update(name: discord_channel.name)
    return channel
  end
end
