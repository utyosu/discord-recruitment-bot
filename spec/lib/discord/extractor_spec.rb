require "./spec/rails_helper"
require "./spec/spec_helper"

describe Extractor do
  around do |e|
    travel_to("2018-3-10 8:03".in_time_zone) { e.run }
  end

  describe ".extraction_time" do
    subject { Extractor.extraction_time(target) }

    context 'when include "まで"' do
      let(:target) { "10:00まで" }
      it { is_expected.to be_nil }
    end

    context 'when include "まで" and valid time' do
      let(:target) { "09:00から10:00まで" }
      it { is_expected.to eq "2018-3-10 9:00".in_time_zone }
    end

    context 'when include "～"' do
      let(:target) { "～10:00" }
      it { is_expected.to be_nil }
    end

    context 'when include "～" and valid time' do
      let(:target) { "09:00～10:00" }
      it { is_expected.to eq "2018-3-10 9:00".in_time_zone }
    end

    context 'when "yyyy/mm/dd hh:mm" style' do
      let(:target) { "2019/03/10 09:00" }
      it { is_expected.to eq "2019-3-10 9:00".in_time_zone }
    end

    context 'when "mm/dd hh:mm" style' do
      let(:target) { "5/10 09:00" }
      it { is_expected.to eq "2018-5-10 9:00".in_time_zone }
    end

    context 'when "hh:mm" style' do
      let(:target) { "10:12" }
      it { is_expected.to eq "2018-3-10 10:12".in_time_zone }
    end

    context 'when "n時m分" style' do
      let(:target) { "9時25分" }
      it { is_expected.to eq "2018-3-10 9:25".in_time_zone }
    end

    context 'when "n時半" style' do
      let(:target) { "9時半" }
      it { is_expected.to eq "2018-3-10 9:30".in_time_zone }
    end

    context 'when "n時" style' do
      let(:target) { "10時" }
      it { is_expected.to eq "2018-3-10 10:00".in_time_zone }
    end

    context "when 丑三つ時" do
      let(:target) { "丑三つ時" }
      it { is_expected.to eq "2018-3-11 2:00".in_time_zone }
    end

    context 'when "n時間" is not "n時"' do
      let(:target) { "9時間" }
      it { is_expected.to eq nil }
    end

    context "when target time arrive not yet" do
      let(:target) { "18:00" }
      it { is_expected.to eq "2018-3-10 18:00".in_time_zone }
    end

    context "when target time is pasted (AM)" do
      let(:target) { "7:00" }
      it { is_expected.to eq "2018-3-10 19:00".in_time_zone }
    end

    context "when target time is pasted (PM)" do
      let(:target) { "18:00" }
      it do
        travel_to "2018-3-10 19:00".in_time_zone
        is_expected.to eq "2018-3-11 18:00".in_time_zone
      end
    end

    context "when target time is pasted with diff over 12h" do
      let(:target) { "1:00" }
      it do
        travel_to "2018-3-10 23:00".in_time_zone
        is_expected.to eq "2018-3-11 1:00".in_time_zone
      end
    end

    context "when over 24:00" do
      let(:target) { "25:00" }
      it { is_expected.to eq "2018-3-11 1:00".in_time_zone }
    end

    context 'when include "明日"' do
      let(:target) { "明日の9時" }
      it { is_expected.to eq "2018-3-11 9:00".in_time_zone }
    end
  end

  describe ".extraction_recruit_user_count" do
    subject { Extractor.extraction_recruit_user_count(target) }

    context "when has one number" do
      let(:target) { "@5" }
      it { is_expected.to eq 5 }
    end

    context "when has two numbers" do
      let(:target) { "@1or3" }
      it { is_expected.to eq 3 }
    end

    context "when has time and number" do
      let(:target) { "3:12@4" }
      it { is_expected.to eq 4 }
    end

    context "when has datetime and number" do
      let(:target) { "2018/10/4 5:12@6" }
      it { is_expected.to eq 6 }
    end

    context "when has no numbers" do
      let(:target) { "hogehoge" }
      it { is_expected.to be_nil }
    end
  end
end
