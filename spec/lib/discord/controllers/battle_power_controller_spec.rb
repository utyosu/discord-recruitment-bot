require './spec/rails_helper'
require './spec/spec_helper'

describe BattlePowerController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author) }

  describe '#do' do
    before { described_class.do(message_event) }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'battle_power')
    end

    it 'have message with author name' do
      expect(message_event).to be_include_message(author.name)
    end
  end
end
