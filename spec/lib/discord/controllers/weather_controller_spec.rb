require './spec/rails_helper'
require './spec/spec_helper'

describe WeatherController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: content) }

  describe '#get' do
    before do
      ENV['DISCORD_BOT_GEOCODE_APPID'] = 'hoge'
      ENV['DISCORD_BOT_WEATHER_APPID'] = 'fuga'
      allow(HTTP).to receive(:get).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
      described_class.get(message_event)
    end

    let(:content) { '新宿の天気' }
    let(:status) { 404 }
    let(:body) { '{"Feature":["東京都新宿区"]}' }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'weather')
    end
  end
end
