require "./spec/rails_helper"
require "./spec/spec_helper"

describe RecruitmentShowAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[recruitment pm], Settings.keyword.recruitment.show.sample
  end

  describe "#execute" do
    subject { described_class.new.execute(recruitment_channel) }

    let(:recruitment_channel) { build(:fake_channel) }

    context "when exist active recruitment" do
      before { create(:recruitment, content: recruitment_content) }
      let(:recruitment_content) { "わっしょい＠９９９" }
      it do
        subject
        expect(recruitment_channel).to be_include_message(recruitment_content)
      end
    end

    context "when not exist active recruitment" do
      it do
        subject
        expect(recruitment_channel).to be_include_message(I18n.t("recruitment.not_found"))
      end
    end
  end
end
