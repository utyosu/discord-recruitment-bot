require "./spec/rails_helper"
require "./spec/spec_helper"

describe RecruitmentBase do
  before do
    allow(TwitterController).to receive(:new).and_return(double.as_null_object)
  end

  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: message) }
  let(:message) { "" }
  let(:recruitment_channel) { build(:fake_channel) }

  describe "#show" do
    subject { described_class.new.show(recruitment_channel) }

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

  describe "#destroy_expired_recruitment" do
    subject { described_class.new.destroy_expired_recruitment(recruitment_channel) }
    context "when expire standard-recruitment" do
      let(:recruitment) { create(:recruitment) }
      before { recruitment.update(created_at: 1.hours.ago) }
      it { expect { subject }.to change(Recruitment.active, :count).by(-1) }
    end

    context "when expire reserved-recruitment" do
      let(:recruitment) { create(:recruitment) }
      before { recruitment.update(reserve_at: 1.hours.ago) }
      it { expect { subject }.to change(Recruitment.active, :count).by(-1) }
    end

    context "when little expire reserved-recruitment that is not full" do
      let(:recruitment) { create(:recruitment) }
      before { recruitment.update(reserve_at: 1.minutes.ago) }
      it { expect { subject }.to change(Recruitment.active, :count).by(0) }
    end

    context "when little expire reserved-recruitment that is full" do
      let(:recruitment) { create(:recruitment, content: "サーモン＠１") }
      before do
        recruitment.join(create(:user))
        recruitment.update(reserve_at: 1.minutes.ago)
      end
      it { expect { subject }.to change(Recruitment.active, :count).by(-1) }
    end
  end
end
