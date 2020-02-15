FactoryBot.define do
  factory :recruitment do
    content { "#{Faker::Lorem.sentence}@#{Faker::Number.between(from: 1, to: 9)}" }

    transient do
      user { create(:user) }
    end

    after(:create) do |recruitment, evaluator|
      recruitment.join(evaluator.user)
    end
  end
end
