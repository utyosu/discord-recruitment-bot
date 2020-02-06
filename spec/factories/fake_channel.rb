class FakeChannel
  attr_accessor :type, :id, :name

  def initialize
    @messages = []
  end

  def send_message(text)
    @messages << text
  end

  def include_message?(text)
    @messages.any?{|m| m.include?(text)}
  end

  def text?
    type == 0
  end

  def pm?
    type == 1
  end

  def voice?
    type == 2
  end

  def group?
    type == 3
  end

  def category?
    type == 4
  end
end

FactoryBot.define do
  factory :fake_channel do
    type { Faker::Number.between(from: 0, to: 4) }
    id { Faker::Number.unique.number(digits: 18) }
    name { Faker::Lorem.sentence }
  end
end
