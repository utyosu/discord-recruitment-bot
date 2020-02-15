require "./spec/rails_helper"
require "./spec/spec_helper"

describe RecruitmentCloseAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[recruitment], Settings.keyword.recruitment.close.sample
  end

  describe "#execute" do
    before do
      # allow(Helper).to receive(:get_channel).and_return(recruitment_channel)
      allow(TwitterController).to receive(:new).and_return(double.as_null_object)
    end

    # let(:recruitment_channel) { build(:fake_channel) }

    subject { described_class.new.execute(message_event) }

    context "when exsit recruitment" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠１") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.close.sample}" }
      it {
        subject
        expect(recruitment.reload).to_not be_enable
        expect(message_event).to be_include_message(I18n.t("recruitment.close", name: author.name, label_id: Recruitment.first.label_id))
      }
    end

    context "when not exist recruitment" do
      let(:discord_content) { "999#{Settings.keyword.recruitment.close.sample}" }
      it { expect { subject }.to_not raise_error }
    end
  end
end
