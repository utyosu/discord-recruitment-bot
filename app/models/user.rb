class User < ApplicationRecord
  def self.get_by_discord_user(discord_user)
    user = User.find_or_initialize_by(discord_id: discord_user.id)
    user.update(name: discord_user.display_name) if discord_user.respond_to?(:display_name)
    return user
  end
end
