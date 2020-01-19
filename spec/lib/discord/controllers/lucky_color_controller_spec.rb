require './spec/rails_helper'
require './spec/spec_helper'

describe LuckyColorController do
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
      allow(OpenURI).to receive(:open_uri)
      allow(message_event).to receive(:send_file)
      allow(File).to receive(:open)
      allow(File).to receive(:delete)
      described_class.do(message_event)
    end

    context 'when have error' do
      # TODO
    end

    context 'when success' do
      let(:status) { 200 }
      let(:body) { '{"items":[{"link":"http://www.example.com/sample.jpg"}]}' }

      it 'save activity' do
        expect(Activity.last).to have_attributes(user: author, content: 'lucky_color')
      end
    end
  end
end
