require './spec/rails_helper'
require './spec/spec_helper'

describe InsiderGameController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author) }

  # TODO: テストするためにはリファクタが必要
  # describe '#insider_game' do
  #   before do
  #     described_class.insider_game(message_event)
  #   end

  #   it 'save activity' do
  #     expect(Activity.last).to have_attributes(user: author, content: 'insider_game')
  #   end
  # end
end
