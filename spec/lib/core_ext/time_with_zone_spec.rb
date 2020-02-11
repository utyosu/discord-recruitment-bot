require "./spec/rails_helper"
require "./spec/spec_helper"

describe ActiveSupport::TimeWithZone do
  describe ".simply" do
    subject { target.to_simply }

    before do
      travel_to Time.zone.parse("2020-01-01 12:00")
      freeze_time
    end

    after do
      unfreeze_time
    end

    context "when datetime is today" do
      let(:target) { Time.zone.parse("2020-01-01 14:00") }

      it { is_expected.to eq "14:00" }
    end

    context "when datetime is this year" do
      let(:target) { Time.zone.parse("2020-03-04 15:00") }

      it { is_expected.to eq "03/04 15:00" }
    end

    context "when datetime is not this year" do
      let(:target) { Time.zone.parse("2021-01-01 16:00") }

      it { is_expected.to eq "2021/01/01 16:00" }
    end
  end
end
