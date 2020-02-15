require "./spec/rails_helper"
require "./spec/spec_helper"

describe InteractionDestroyAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[play], Settings.keyword.interaction.destroy.sample
  end

  describe "#execute" do
    before { described_class.new.execute(message_event) }

    let(:discord_content) { "#{Settings.keyword.interaction.destroy.sample} ほげ" }

    it "save activity" do
      expect(Activity.last).to have_attributes(user: author, content: "interaction_destroy")
    end
  end
end
