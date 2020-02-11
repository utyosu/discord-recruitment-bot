require "./spec/rails_helper"
require "./spec/spec_helper"

describe ActionSelector do
  action_selector = ActionSelector.new
  describe ".execute" do
    let(:message_event) { build(:fake_message_event) }

    before do
      action_selector.instance_variable_get(:@actions).each do |action|
        allow(action).to receive(:execute?).and_return(false)
      end
    end

    action_selector.instance_variable_get(:@actions).each do |action|
      describe action.class do
        let(:target_action) { action }

        context "when execute" do
          before do
            allow(target_action).to receive(:execute?).and_return(true)
            allow(target_action).to receive(:execute)
            action_selector.execute(message_event)
          end

          it { expect(target_action).to have_received(:execute) }
        end

        context "when not execute" do
          before do
            allow(target_action).to receive(:execute?).and_return(false)
            allow(target_action).to receive(:execute)
            action_selector.execute(message_event)
          end

          it { expect(target_action).to_not have_received(:execute) }
        end
      end
    end
  end
end
