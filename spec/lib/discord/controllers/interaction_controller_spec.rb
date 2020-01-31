require './spec/rails_helper'
require './spec/spec_helper'

describe InteractionController do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: message) }

  describe '#create' do
    before { described_class.create(message_event) }

    let(:message) { "#{Settings.keyword.interaction.create.sample} ほげ ふが" }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'interaction_create')
    end
  end

  describe '#destroy' do
    before { described_class.destroy(message_event) }

    let(:message) { "#{Settings.keyword.interaction.destroy.sample} ほげ" }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'interaction_destroy')
    end
  end

  describe '#response' do
    let!(:interaction) { create(:interaction, keyword: 'ほげ') }

    let(:message) { 'ほげ' }

    before { described_class.response(message_event) }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'interaction_response')
    end
  end
end
