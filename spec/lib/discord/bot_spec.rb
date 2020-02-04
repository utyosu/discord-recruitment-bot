require './spec/rails_helper'
require './spec/spec_helper'

describe Bot do
  describe '.sequence' do
    before do
      allow(Discordrb::Commands::CommandBot).to receive(:new).and_return(bot)
      allow(Helper).to receive(:get_channel).and_return(channel)
      allow(Slack::Web::Client).to receive(:new).and_return(slack)
      allow(target).to receive(:sleep).and_return(nil)
      allow(logger).to receive(:error)
      allow(Timers::Group).to receive(:new).and_return(timers)
      allow(timers).to receive(:wait).and_raise(error)
      target.sequence
    end

    let(:timers) { Timers::Group.new }
    let(:logger) { Rails.logger }
    let(:target) { described_class.new }
    let(:bot) { double(:bot).as_null_object }
    let(:slack) { double(:slack).as_null_object }
    let(:channel) { build(:fake_channel) }
    let(:error) { RuntimeError.new('this is test error') }

    it 'write logger' do
      expect(logger).to have_received(:error).with(I18n.t('bot.reboot')).ordered
      expect(logger).to have_received(:error).with(error.full_message).ordered
    end
  end
end
