require "./spec/rails_helper"
require "./spec/spec_helper"

describe HelpAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[recruitment], Settings.keyword.help.sample
  end

  describe "#execute" do
    before { described_class.new.execute(message_event) }

    it "have help message" do
      expect(message_event).to be_include_message(I18n.t("help.recruitment"))
    end
  end
end
