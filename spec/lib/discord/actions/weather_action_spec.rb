require './spec/rails_helper'
require './spec/spec_helper'

describe WeatherAction do
  include_context 'basic message_event'

  describe '#execute?' do
    it_behaves_like 'execute?', Settings.keyword.weather.sample
  end

  describe '#execute' do
    before do
      allow(HTTP).to receive(:get).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
      described_class.new.execute(message_event)
    end

    let(:discord_content) { "新宿#{Settings.keyword.weather.sample}" }
    let(:status) { 404 }
    let(:body) { '{"Feature":["東京都新宿区"]}' }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'weather')
    end
  end
end
