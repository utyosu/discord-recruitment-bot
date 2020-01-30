require './spec/rails_helper'
require './spec/spec_helper'

describe InsiderGameController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: "インサイダーゲーム #{subject}") }
  let(:subject) { 'apple' }
  let(:insider) { nil }
  let(:bot) { nil }

  describe '#do' do
    before do
      allow(message_event).to receive(:author).and_return(discord_author)
      allow(InsiderGameController).to receive(:get_voice_channel).and_return(voice_channels)
      allow(InsiderGameController).to receive(:decide_insider).and_return(insider)
      allow_any_instance_of(FakeDiscordUser).to receive(:pm)
      described_class.do(message_event, bot)
    end

    context 'when voice channel is blank' do
      let(:voice_channels) { nil }

      it 'save activity' do
        expect(Activity.last).to have_attributes(user: author, content: 'insider_game')
      end

      it 'send private message with no voice channel' do
        expect(discord_author).to have_received(:pm).with(I18n.t('insider_game.error_no_voice_channel'))
      end
    end

    context 'when insider is blank' do
      let(:voice_channels) { OpenStruct.new(users: [discord_author]) }

      it 'save activity' do
        expect(Activity.last).to have_attributes(user: author, content: 'insider_game')
      end

      it 'send private message with no insiders' do
        expect(discord_author).to have_received(:pm).with(I18n.t('insider_game.error_no_insider'))
      end
    end

    context 'when a insider is elected' do
      let(:voice_channels) { OpenStruct.new(users: [discord_author, insider, common]) }
      let(:insider) { build(:fake_discord_user) }
      let(:common) { build(:fake_discord_user) }

      it 'save activity' do
        expect(Activity.last).to have_attributes(user: author, content: 'insider_game')
      end

      it 'send private message with master' do
        expect(discord_author).to have_received(:pm).with(I18n.t('insider_game.master', subject: subject))
      end

      it 'send private message with insider' do
        expect(insider).to have_received(:pm).with(I18n.t('insider_game.insider', subject: subject))
      end

      it 'send private message with insider' do
        expect(common).to have_received(:pm).with(I18n.t('insider_game.common'))
      end
    end
  end
end
