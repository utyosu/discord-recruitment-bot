class Channel < ApplicationRecord
  def self.get_by_discord_channel(channel)
    channel = Channel.find_or_initialize_by(channel_id: channel.id)
    channel.update(name: channel.name)
    return channel
  end
end
