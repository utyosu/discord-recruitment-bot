require './spec/rails_helper'
require './spec/spec_helper'

describe RecruitmentController do
  before do
    $recruitment_channel = build(:fake_message_event)
    ENV['DISCORD_BOT_TWITTER_DISABLE'] = "1"
  end

  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: message) }
  let(:message) { '' }

  describe '#show' do
    subject { RecruitmentController.show }

    context 'when exist active recruitment' do
      before { create(:recruitment, content: recruitment_content) }
      let(:recruitment_content) { "わっしょい＠９９９" }
      it do
        subject
        expect($recruitment_channel).to be_include_message(recruitment_content)
      end
    end

    context 'when not exist active recruitment' do
      it do
        subject
        expect($recruitment_channel).to be_include_message(I18n.t('recruitment.not_found'))
      end
    end
  end

  describe '#destroy_expired_recruitment' do
    subject { RecruitmentController.destroy_expired_recruitment }
    context 'when expire standard-recruitment' do
      let(:recruitment) { create(:recruitment) }
      before { recruitment.update(created_at: 1.hours.ago) }
      it { expect { subject }.to change(Recruitment.active, :count).by(-1) }
    end

    context 'when expire reserved-recruitment' do
      let(:recruitment) { create(:recruitment) }
      before { recruitment.update(reserve_at: 1.hours.ago) }
      it { expect { subject }.to change(Recruitment.active, :count).by(-1) }
    end

    context 'when little expire reserved-recruitment that is not full' do
      let(:recruitment) { create(:recruitment) }
      before { recruitment.update(reserve_at: 1.minutes.ago) }
      it { expect { subject }.to change(Recruitment.active, :count).by(0) }
    end

    context 'when little expire reserved-recruitment that is full' do
      let(:recruitment) { create(:recruitment, content: "サーモン＠１") }
      before do
        recruitment.join(create(:user))
        recruitment.update(reserve_at: 1.minutes.ago)
      end
      it { expect { subject }.to change(Recruitment.active, :count).by(-1) }
    end
  end

  describe '#open' do
    subject { RecruitmentController.open(message_event) }

    context 'when standard recruit' do
      let(:message) { "リーグマッチ＠３" }
      it { expect { subject }.to change(Recruitment, :count).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t('recruitment.open_standard', name: author.name, label_id: Recruitment.first.label_id, time: (Recruitment.first.created_at + Settings::EXPIRE_TIME).to_simply))
      end
    end

    context 'when reserved recruit' do
      let(:message) { "１２：００からリーグマッチ＠３" }
      it { expect { subject }.to change(Recruitment, :count).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t('recruitment.open_reserved', name: author.name, label_id: Recruitment.first.label_id, time: Recruitment.first.reserve_at.to_simply))
      end
    end
  end

  describe '#close' do
    subject { RecruitmentController.close(message_event) }

    context 'when exsit recruitment' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠１") }
      let(:message) { "#{recruitment.label_id}しめ" }
      it {
        subject
        expect(recruitment.reload).to_not be_enable
        expect(message_event).to be_include_message(I18n.t('recruitment.close', name: author.name, label_id: Recruitment.first.label_id))
      }
    end

    context 'when not exist recruitment' do
      let(:message) { "999しめ" }
      it { expect{ subject }.to_not raise_error }
    end
  end

  describe '#join' do
    subject { RecruitmentController.join(message_event) }

    context 'when recruitment has 2 capacity' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:message) { "#{recruitment.label_id}参加" }
      it { expect{ subject }.to change(recruitment, :reserved).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t('recruitment.join', name: author.name, label_id: recruitment.label_id))
        expect(message_event).to_not be_include_message(I18n.t('recruitment.one_time_close', label_id: recruitment.label_id))
        expect(recruitment.reload).to be_enable
      end
    end

    context 'when recruitment has 1 capacity' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠１") }
      let(:message) { "#{recruitment.label_id}参加" }
      before { recruitment.join(create(:user)) }
      it { expect{ subject }.to change(recruitment, :reserved).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t('recruitment.join', name: author.name, label_id: recruitment.label_id))
        expect(message_event).to be_include_message(I18n.t('recruitment.one_time_close', label_id: recruitment.label_id))
        expect(recruitment.reload).to_not be_enable
      end
    end

    context 'when recruitment has 1 capacity and reserved' do
      let(:recruitment) { create(:recruitment, content: "#{1.hours.since.to_simply}ほげ＠１") }
      let(:message) { "#{recruitment.label_id}参加" }
      before { recruitment.join(create(:user)) }
      it { expect{ subject }.to change(recruitment, :reserved).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t('recruitment.join', name: author.name, label_id: recruitment.label_id))
        expect(message_event).to_not be_include_message(I18n.t('recruitment.on_time_close', label_id: recruitment.label_id))
        expect(message_event).to be_include_message(I18n.t('recruitment.reserve_full', time: recruitment.reserve_at.to_simply))
        expect(recruitment.reload).to be_enable
      end
    end

    context 'when not found recruitment' do
      let(:message) { "999参加" }
      it { expect{ subject }.to_not raise_error }
    end

    context 'when message has two number' do
      let(:message) { "1と2に参加" }
      it do
        subject
        expect(message_event).to be_include_message(I18n.t('recruitment.error_two_numbers'))
      end
    end
  end

  describe '#leave' do
    subject { RecruitmentController.leave(message_event) }

    context 'when joined recruitment' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:message) { "#{recruitment.label_id}キャンセル" }
      before { recruitment.join(author) }
      it { expect { subject }.to change(recruitment, :reserved).by(-1) }
    end

    context 'when recruitment author is leaved' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:message) { "#{recruitment.label_id}キャンセル" }
      let(:discord_author) { build(:fake_discord_user, id: recruitment.author.discord_id) }
      it { expect { subject }.to change(recruitment, :reserved).by(-1) }
    end

    context 'when not joined user leaved' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      let(:message) { "#{recruitment.label_id}キャンセル" }
      it { expect { subject }.to change(recruitment, :reserved).by(0) }
    end

    context 'when not found recruitment' do
      let(:message) { "999キャンセル" }
      it { subject }
    end
  end

  describe '#resurrection' do
    subject { RecruitmentController.resurrection(message_event) }
    let(:message) { "復活" }

    context 'when exist closed recruitment' do
      let(:recruitment) { create(:recruitment, content: "ほげ＠２") }
      before { recruitment.update(enable: false) }
      it { expect { subject }.to change(Recruitment.active, :count).by(1) }
      it do
        subject
        expect(recruitment.reload).to be_enable
      end
    end

    context 'when not exist closed recruitment' do
      it { expect { subject }.to change(Recruitment.active, :count).by(0) }
    end
  end
end
