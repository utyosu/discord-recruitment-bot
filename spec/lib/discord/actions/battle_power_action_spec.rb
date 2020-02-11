require './spec/rails_helper'
require './spec/spec_helper'

describe BattlePowerAction do
  include_context 'basic message_event'

  describe '#execute?' do
    it_behaves_like 'execute?', Settings.keyword.battle_power.sample
  end

  describe '#execute' do
    before { described_class.new.execute(message_event) }

    it 'save activity' do
      expect(Activity.last).to have_attributes(user: author, content: 'battle_power')
    end

    it 'have message with author name' do
      expect(message_event).to be_include_message(author.name)
    end
  end
end
