require './spec/rails_helper'
require './spec/spec_helper'

describe TalkController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: content) }

  describe '#do' do
    before do
      allow(HTTP).to receive(:post).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
      described_class.do(message_event)
    end

    let(:content) { 'ロボちょすおはよう' }
    let(:status) { 200 }
    let(:body) { '{"status":"0","results":[{"reply":"おはようございます"}]}' }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'talk')
    end
  end
end
