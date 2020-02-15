require "./spec/rails_helper"
require "./spec/spec_helper"

describe RecruitmentLeaveAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[recruitment], Settings.keyword.recruitment.leave.sample
  end

  describe "#execute" do
    subject { described_class.new.execute(message_event) }

    before do
      allow(TwitterController).to receive(:new).and_return(double.as_null_object)
    end

    context "when leave organizer" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠３", user: organizer) }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.leave.sample}" }
      let(:organizer) { author }

      it { expect { subject }.to change(recruitment, :reserved).by(-1) }

      it "is not enabled" do
        subject
        expect(recruitment.reload).to have_attributes(enable: false)
      end
    end

    context "when leave member" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠３", user: organizer) }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.leave.sample}" }
      let(:organizer) { create(:user) }
      let(:member) { author }

      before do
        recruitment.join(member)
      end

      it { expect { subject }.to change(recruitment, :reserved).by(-1) }
      it do
        subject
        expect(recruitment.reload).to have_attributes(enable: true)
      end
    end

    context "when not joined user leaved" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.leave.sample}" }

      it { expect { subject }.to change(recruitment, :reserved).by(0) }
    end

    context "when not found recruitment" do
      let(:discord_content) { "999#{Settings.keyword.recruitment.leave.sample}" }

      it { expect { subject }.to_not raise_error }
    end
  end
end
