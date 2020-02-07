class FakeDiscordUser
  attr_accessor :id, :display_name

  def pm(message)
    # Do nothing
  end
end

FactoryBot.define do
  factory :fake_discord_user do
    sequence(:display_name) { Faker::Name.name }
    sequence(:id) { Faker::Number.number(digits: 18) }
  end
end
