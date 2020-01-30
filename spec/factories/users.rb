FactoryBot.define do
  factory :user do
    sequence(:name) { Faker::Name.name }
    sequence(:discord_id) { Faker::Number.number(digits: 18) }
  end
end
