require "./spec/rails_helper"
require "./spec/spec_helper"

describe TalkAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", Settings.keyword.talk.sample
  end

  describe "#execute" do
    before do
      allow(HTTP).to receive(:post).and_return(
        OpenStruct.new(
          status: status,
          body: body,
        )
      )
      described_class.new.execute(message_event)
    end

    let(:discord_content) { "#{Settings.keyword.talk.sample}おはよう" }
    let(:status) { 200 }
    let(:body) { '{"status":"0","results":[{"reply":"おはようございます"}]}' }

    it "save activity" do
      expect(Activity.last).to have_attributes(user: author, content: "talk")
    end
  end
end
