require "./spec/rails_helper"
require "./spec/spec_helper"

describe NicknameAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[play], Settings.keyword.nickname.sample
  end

  describe "#execute" do
    before { described_class.new.execute(message_event) }

    it "save activity" do
      expect(Activity.last).to have_attributes(user: author, content: "nickname")
    end
  end
end
