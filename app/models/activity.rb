class Activity < ApplicationRecord
  belongs_to :user

  enum content: {
    battle_power: 1,
    food_porn: 2,
    fortune: 3,
    insider_game: 4,
    interaction_create: 5,
    interaction_destroy: 6,
    interaction_response: 7,
    interaction_list: 8,
    lucky_color: 9,
    nickname: 10,
    talk: 11,
    weapon: 12,
    weather: 13,
  }

  def self.add(discord_user, content)
    Activity.create(user: User.get_by_discord_user(discord_user), content: content)
  end
end
