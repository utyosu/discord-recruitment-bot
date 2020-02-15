require "./spec/rails_helper"
require "./spec/spec_helper"

describe RecruitmentJoinAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[recruitment], Settings.keyword.recruitment.join.sample
  end

  describe "#execute" do
    subject { described_class.new.execute(message_event) }

    before do
      allow(Helper).to receive(:get_channel).and_return(recruitment_channel)
      allow(TwitterController).to receive(:new).and_return(double.as_null_object)
    end

    let(:recruitment_channel) { build(:fake_channel) }

    context "when recruitment has 2 capacity" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.join.sample}" }

      it { expect { subject }.to change(recruitment, :reserved).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t("recruitment.join", name: author.name, label_id: recruitment.label_id))
        expect(message_event).to_not be_include_message(I18n.t("recruitment.one_time_close", label_id: recruitment.label_id))
        expect(recruitment.reload).to be_enable
      end
    end

    context "when recruitment has 1 capacity" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠１") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.join.sample}" }
      before { recruitment.join(create(:user)) }
      it { expect { subject }.to change(recruitment, :reserved).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t("recruitment.join", name: author.name, label_id: recruitment.label_id))
        expect(message_event).to be_include_message(I18n.t("recruitment.one_time_close", label_id: recruitment.label_id))
        expect(recruitment.reload).to_not be_enable
      end
    end

    context "when recruitment has 1 capacity and reserved" do
      let(:recruitment) { create(:recruitment, content: "#{1.hours.since.to_simply}ほげ＠１") }
      let(:discord_content) { "#{recruitment.label_id}#{Settings.keyword.recruitment.join.sample}" }
      before { recruitment.join(create(:user)) }
      it { expect { subject }.to change(recruitment, :reserved).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t("recruitment.join", name: author.name, label_id: recruitment.label_id))
        expect(message_event).to_not be_include_message(I18n.t("recruitment.on_time_close", label_id: recruitment.label_id))
        expect(message_event).to be_include_message(I18n.t("recruitment.reserve_full", time: recruitment.reserve_at.to_simply))
        expect(recruitment.reload).to be_enable
      end
    end

    context "when not found recruitment" do
      let(:discord_content) { "999#{Settings.keyword.recruitment.join.sample}" }
      it { expect { subject }.to_not raise_error }
    end

    context "when message has two number" do
      let(:discord_content) { "1と2に#{Settings.keyword.recruitment.join.sample}" }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t("recruitment.error_two_numbers"))
      end
    end

    context "with some keywords" do
      let(:recruitment) { create(:recruitment, content: "ほげ＠１") }

      Settings.keyword.recruitment.join.each do |keyword|
        let(:discord_content) { "1#{keyword}" }

        it { expect { subject }.to change(recruitment, :reserved).by(1) }
      end
    end
  end
end
