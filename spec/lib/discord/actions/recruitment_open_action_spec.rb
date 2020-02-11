require './spec/rails_helper'
require './spec/spec_helper'

describe RecruitmentOpenAction do
  include_context 'basic message_event'

  describe '#execute?' do
    it_behaves_like 'execute?', '@1'
  end

  describe '#execute' do
    subject { described_class.new.execute(message_event) }

    before do
      allow(Helper).to receive(:get_channel).and_return(recruitment_channel)
      allow(TwitterController).to receive(:new).and_return(double.as_null_object)
    end

    let(:recruitment_channel) { build(:fake_channel) }

    context 'when standard recruit' do
      let(:discord_content) { "リーグマッチ＠３" }
      it { expect { subject }.to change(Recruitment, :count).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(
          I18n.t(
            'recruitment.open_standard',
            name: author.name,
            label_id: Recruitment.first.label_id,
            time: (Recruitment.first.created_at + Settings.recruitment.expire_sec).to_simply
          )
        )
      end
    end

    context 'when reserved recruit' do
      let(:discord_content) { "１２：００からリーグマッチ＠３" }
      it { expect { subject }.to change(Recruitment, :count).by(1) }
      it do
        subject
        expect(message_event).to be_include_message(
          I18n.t(
            'recruitment.open_reserved',
            name: author.name,
            label_id: Recruitment.first.label_id,
            time: Recruitment.first.reserve_at.to_simply
          )
        )
      end
    end
  end
end
