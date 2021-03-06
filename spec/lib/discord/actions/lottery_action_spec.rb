require "./spec/rails_helper"
require "./spec/spec_helper"

describe LotteryAction do
  include_context "basic message_event"

  describe "#execute?" do
    it_behaves_like "execute?", %i[play], Settings.keyword.lottery.sample
  end

  describe "#execute" do
    subject { described_class.new }

    it "save activity" do
      subject.execute(message_event)
      expect(Activity.last).to have_attributes(user: author, content: "lottery")
    end

    context "rand return 0" do
      before { allow(subject).to receive(:rand).and_return(0) }

      it "rank1" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.rank1", name: discord_author.display_name))
      end
    end

    context "rand return 5000" do
      before { allow(subject).to receive(:rand).and_return(5000) }

      it "rank2" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.rank2", name: discord_author.display_name))
      end
    end

    context "rand return 7500" do
      before { allow(subject).to receive(:rand).and_return(7500) }

      it "rank3" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.rank3", name: discord_author.display_name))
      end
    end

    context "rand return 800000" do
      before { allow(subject).to receive(:rand).and_return(800_000) }

      it "rank4" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.rank4", name: discord_author.display_name))
      end
    end

    context "rand return 2000000" do
      before { allow(subject).to receive(:rand).and_return(2_000_000) }

      it "rank5" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.rank5", name: discord_author.display_name))
      end
    end

    context "rand return 5000000" do
      before { allow(subject).to receive(:rand).and_return(5_000_000) }

      it "miss" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.miss", name: discord_author.display_name))
      end
    end

    context "exist limit count in today" do
      before { create_list(:activity, Settings.lottery.limit, user: author, content: :lottery) }

      it "restrictions" do
        subject.execute(message_event)
        expect(message_event).to be_include_message(I18n.t("lottery.over", limit: Settings.lottery.limit))
      end
    end

    context "exist limit count in yesterday" do
      before { create_list(:activity, Settings.lottery.limit, user: author, content: :lottery, created_at: Time.zone.now.ago(1.day)) }

      it "not restrictions" do
        subject.execute(message_event)
        expect(message_event).to_not be_include_message(I18n.t("lottery.over", limit: Settings.lottery.limit))
      end
    end
  end
end
