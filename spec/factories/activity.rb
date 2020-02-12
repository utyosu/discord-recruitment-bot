FactoryBot.define do
  factory :activity do
    user { create(:user) }
    content { Activity.contents.values.sample }
  end
end
