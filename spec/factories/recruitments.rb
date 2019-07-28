FactoryBot.define do
  factory :recruitment do
    content { 'ほげ＠１' }
    after(:create) do |recruitment|
      recruitment.join(create(:user))
    end
  end
end
