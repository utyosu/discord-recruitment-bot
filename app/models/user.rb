class User < ApplicationRecord
  def self.get_by_discord_user(discord_user)
    user = User.find_or_initialize_by(discord_id: discord_user.id)
    display_name = discord_user.try(:display_name)
    user.update(name: display_name) if display_name.present?
    return user
  end
end
