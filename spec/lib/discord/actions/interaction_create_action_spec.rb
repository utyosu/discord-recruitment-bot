require "./spec/rails_helper"
require "./spec/spec_helper"

describe InteractionCreateAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[play], Settings.keyword.interaction.create.sample
  end

  describe "#execute" do
    before { described_class.new.execute(message_event) }

    let(:discord_content) { "#{Settings.keyword.interaction.create.sample} ほげ ふが" }

    it "save activity" do
      expect(Activity.last).to have_attributes(user: author, content: "interaction_create")
    end
  end
end
