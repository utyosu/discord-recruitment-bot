FactoryBot.define do
  factory :recruitment do
    content { "#{Faker::Lorem.sentence}@#{Faker::Number.between(from: 1, to: 9)}" }
    after(:create) do |recruitment|
      recruitment.join(create(:user))
    end
  end
end
