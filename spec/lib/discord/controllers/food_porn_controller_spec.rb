require './spec/rails_helper'
require './spec/spec_helper'

describe FoodPornController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author) }

  describe '#do' do
    before do
      allow(HTTP).to receive(:get).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
    end

    context 'when have error' do
      before do
        described_class.do(message_event)
      end

      let(:status) { 404 }
      let(:body) { '' }

      it 'save activity' do
        expect(Activity.last).to have_attributes(user: author, content: 'food_porn')
      end

      it 'have error messagee' do
        expect(message_event).to be_include_message(I18n.t('food_porn.error'))
      end
    end

    context 'when success' do
      before do
        allow(OpenURI).to receive(:open_uri)
        allow(message_event).to receive(:send_file)
        allow(File).to receive(:open)
        allow(File).to receive(:delete)
        described_class.do(message_event)
      end

      let(:status) { 200 }
      let(:body) { '{"items":[{"link":"http://www.example.com/sample.jpg"}]}' }

      it 'save activity' do
        expect(Activity.last).to have_attributes(user: author, content: 'food_porn')
      end

      it 'is call send_file' do
        expect(message_event).to have_received(:send_file).once
      end
    end
  end
end
