require './spec/rails_helper'
require './spec/spec_helper'

describe ActionSelector do
  describe '.get_message' do
    before do
      allow(Helper).to receive(:get_channel).and_return(nil)
      allow(Helper).to receive(:recruitment?).and_return(recruitment)
      allow(Helper).to receive(:pm?).and_return(pm)
      allow(Helper).to receive(:play?).and_return(play)
      allow(RecruitmentController).to receive(:show)
      allow(RecruitmentController).to receive(:open)
      allow(RecruitmentController).to receive(:close)
      allow(RecruitmentController).to receive(:join)
      allow(RecruitmentController).to receive(:leave)
      allow(RecruitmentController).to receive(:resurrection)
      allow(HelpController).to receive(:recruitment_help)
      allow(FoodPornController).to receive(:do)
      allow(WeatherController).to receive(:do)
      allow(FortuneController).to receive(:do)
      allow(NicknameController).to receive(:do)
      allow(TalkController).to receive(:do)
      allow(WeaponController).to receive(:do)
      allow(LuckyColorController).to receive(:do)
      allow(BattlePowerController).to receive(:do)
      allow(InsiderGameController).to receive(:do)
      allow(InteractionController).to receive(:create)
      allow(InteractionController).to receive(:destroy)
      allow(InteractionController).to receive(:response)
      described_class.get_message(message_event, bot)
    end

    let(:discord_author) { build(:fake_discord_user) }
    let(:author) { User.get_by_discord_user(discord_author) }
    let(:message_event) { build(:fake_message_event, author: discord_author, content: content, channel: channel) }
    let(:channel) { build(:fake_channel) }
    let(:recruitment_channel) { channel }
    let(:bot) { nil }

    describe 'private message' do
      let(:recruitment) { false }
      let(:pm) { true }
      let(:play) { false }

      context 'when say search recruitment' do
        let(:content) { '案件' }

        it { expect(RecruitmentController).to have_received(:show) }
      end
    end

    describe 'recruitment channel' do
      let(:recruitment) { true }
      let(:pm) { false }
      let(:play) { false }

      context 'when say search recruitment' do
        let(:content) { '案件' }

        it { expect(RecruitmentController).to have_received(:show) }
      end

      context 'when say recruitment' do
        let(:content) { '＠１' }

        it { expect(RecruitmentController).to have_received(:open) }
      end

      context 'when called RecruitmentController::close' do
        let(:content) { '１しめ' }

        it { expect(RecruitmentController).to have_received(:close) }
      end

      context 'when called RecruitmentController::join' do
        let(:content) { '１参加' }

        it { expect(RecruitmentController).to have_received(:join) }
      end

      context 'when called RecruitmentController::leave' do
        let(:content) { '１キャンセル' }

        it { expect(RecruitmentController).to have_received(:leave) }
      end

      context 'when called RecruitmentController::resurrection' do
        let(:content) { '復活' }

        it { expect(RecruitmentController).to have_received(:resurrection) }
      end

      context 'when called RecruitmentController::leave' do
        let(:content) { '使い方' }

        it { expect(HelpController).to have_received(:recruitment_help) }
      end
    end

    describe 'play channel' do
      let(:recruitment) { false }
      let(:pm) { false }
      let(:play) { true }

      context 'when called RecruitmentController::leave' do
        let(:content) { 'おなかすいた' }

        it { expect(FoodPornController).to have_received(:do) }
      end

      context 'when called WeatherController::do' do
        let(:content) { 'どっかの天気' }

        it { expect(WeatherController).to have_received(:do) }
      end

      context 'when called FortuneController::do' do
        let(:content) { 'おみくじ' }

        it { expect(FortuneController).to have_received(:do) }
      end

      context 'when called NicknameController::do' do
        let(:content) { 'あだ名' }

        it { expect(NicknameController).to have_received(:do) }
      end

      context 'when called WeaponController::do' do
        let(:content) { 'ブキ' }

        it { expect(WeaponController).to have_received(:do) }
      end

      context 'when called LuckyColorController::do' do
        let(:content) { 'ラッキーカラー' }

        it { expect(LuckyColorController).to have_received(:do) }
      end

      context 'when called BattlePowerController::do' do
        let(:content) { '戦闘力' }

        it { expect(BattlePowerController).to have_received(:do) }
      end

      context 'when called TalkController::do' do
        let(:content) { 'ロボちょすおはよう' }

        it { expect(TalkController).to have_received(:do) }
      end

      context 'when called InteractionController::create' do
        let(:content) { '記憶 ほげ ふが' }

        it { expect(InteractionController).to have_received(:create) }
      end

      context 'when called InteractionController::destroy' do
        let(:content) { '忘却 ほげ' }

        it { expect(InteractionController).to have_received(:destroy) }
      end

      context 'when called InteractionController::response' do
        let(:content) { 'ほげ' }

        it { expect(InteractionController).to have_received(:response) }
      end
    end

    describe 'private message' do
      let(:recruitment) { false }
      let(:pm) { true }
      let(:play) { false }

      context 'when called InsiderGameController::do' do
        let(:content) { 'インサイダーゲーム' }

        it { expect(InsiderGameController).to have_received(:do) }
      end
    end
  end
end
