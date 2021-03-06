require "./spec/rails_helper"
require "./spec/spec_helper"

describe Bot do
  describe ".start" do
    before do
      allow(Discordrb::Commands::CommandBot).to receive(:new).and_return(bot)
      allow(Slack::Web::Client).to receive(:new).and_return(slack)
      allow(target).to receive(:sleep).and_return(nil)
      allow(logger).to receive(:error)
      allow(Timers::Group).to receive(:new).and_return(timers)
      allow(timers).to receive(:wait).and_raise(error)
      allow(Logger).to receive(:new).and_return(logger)
      allow(bot).to receive(:connected?).and_return(false)
      target.start
    end

    let(:timers) { Timers::Group.new }
    let(:logger) { Logger.new(nil) }
    let(:target) { described_class.new }
    let(:bot) { double(:bot).as_null_object }
    let(:slack) { double(:slack).as_null_object }
    let(:error) { RuntimeError.new("this is test error") }

    it "write logger" do
      expect(logger).to have_received(:error).with(error.full_message).ordered
    end
  end
end
