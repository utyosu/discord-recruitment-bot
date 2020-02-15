require "./spec/rails_helper"
require "./spec/spec_helper"

describe InteractionResponseAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[play], ""
  end

  describe "#execute" do
    let!(:interaction) { create(:interaction, keyword: "ほげ") }
    let(:discord_content) { "ほげ" }

    before { described_class.new.execute(message_event) }

    it "save activity" do
      expect(Activity.last).to have_attributes(user: author, content: "interaction_response")
    end
  end
end
