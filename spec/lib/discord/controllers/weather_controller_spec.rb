require './spec/rails_helper'
require './spec/spec_helper'

describe WeatherController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: content) }

  describe '#do' do
    before do
      allow(HTTP).to receive(:get).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
      described_class.do(message_event)
    end

    let(:content) { "新宿#{Settings.keyword.weather.sample}" }
    let(:status) { 404 }
    let(:body) { '{"Feature":["東京都新宿区"]}' }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'weather')
    end
  end
end
