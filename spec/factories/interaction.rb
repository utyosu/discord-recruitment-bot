FactoryBot.define do
  factory :interaction do
    user { create(:user) }
    keyword { Faker::Lorem.sentence }
    response { Faker::Lorem.sentence }
  end
end
