class FakeDiscordUser
  attr_accessor :id, :display_name
end

FactoryBot.define do
  factory :fake_discord_user do
    sequence(:display_name) { |n| "TEST_NAME#{n}"}
    sequence(:id) { |n| 10000+n }
  end
end
