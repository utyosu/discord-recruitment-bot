require "./spec/rails_helper"
require "./spec/spec_helper"

describe RecruitmentResurrectionAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[recruitment], Settings.keyword.recruitment.resurrection.sample
  end

  describe "#execute" do
    subject { described_class.new.execute(message_event) }

    before do
      allow(TwitterController).to receive(:new).and_return(double.as_null_object)
    end

    let(:discord_content) { Settings.keyword.recruitment.resurrection.sample }

    context "when exist closed recruitment" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      before { recruitment.update(enable: false) }
      it { expect { subject }.to change(Recruitment.active, :count).by(1) }
      it do
        subject
        expect(recruitment.reload).to be_enable
      end
    end

    context "when not exist closed recruitment" do
      it { expect { subject }.to change(Recruitment.active, :count).by(0) }
    end
  end
end
