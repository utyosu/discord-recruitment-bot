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
      allow(Helper).to receive(:get_channel).and_return(recruitment_channel)
      allow(TwitterController).to receive(:new).and_return(double.as_null_object)
    end

    let(:recruitment_channel) { build(:fake_channel) }

    context "when joined recruitment" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.leave.sample}" }
      before { recruitment.join(author) }
      it { expect { subject }.to change(recruitment, :reserved).by(-1) }
    end

    context "when recruitment author is leaved" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.leave.sample}" }
      let(:discord_author) { build(:fake_discord_user, id: recruitment.author.discord_id) }
      it { expect { subject }.to change(recruitment, :reserved).by(-1) }
    end

    context "when not joined user leaved" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.leave.sample}" }
      it { expect { subject }.to change(recruitment, :reserved).by(0) }
    end

    context "when not found recruitment" do
      let(:discord_content) { "999#{Settings.keyword.recruitment.leave.sample}" }
      it { subject }
    end
  end
end
