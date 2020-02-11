class FakeMessageEvent
  attr_accessor :author, :content, :channel

  def initialize
    @messages = []
  end

  def send_message(text)
    @messages << text
  end

  def include_message?(text)
    @messages.any? { |m| m.include?(text) }
  end

  def send_file(file)
    # Do nothing
  end

  def play?
    raise 'Please implement in stub'
  end

  def recruitment?
    raise 'Please implement in stub'
  end

  def pm?
    raise 'Please implement in stub'
  end

  def match_any_keywords?(keywords)
    content = Helper.to_safe(Helper.get_message_content(self))
    keywords.any? { |keyword| content.match?(Regexp.new(keyword)) }
  end
end

FactoryBot.define do
  factory :fake_message_event do
    sequence(:author) { build(:fake_discord_user) }
    content { Faker::Lorem.sentence }
    channel { build(:fake_channel) }
  end
end
