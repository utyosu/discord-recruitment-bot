FactoryBot.define do
  factory :user_status do
    user { create(:user) }
    channel { create(:channel) }
    interval { Faker::Number.number(digits: 4) }
  end
end
