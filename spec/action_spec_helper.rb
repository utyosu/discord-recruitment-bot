shared_context "basic message_event" do
  let(:discord_author) { build(:fake_discord_user) }
  let(:author) { User.get_by_discord_user(discord_author) }
  let(:message_event) { build(:fake_message_event, author: discord_author, content: discord_content) }
  let(:discord_content) { "" }
end

CHANNELS = %i[recruitment play pm]

shared_examples "execute?" do |executable_channels, keywords|
  subject { described_class.new.execute?(message_event) }

  let(:discord_content) { keywords }

  CHANNELS.each do |channel|
    describe "with #{channel} channel" do
      before do
        allow(message_event).to receive(:recruitment?).and_return(channel == :recruitment)
        allow(message_event).to receive(:play?).and_return(channel == :play)
        allow(message_event).to receive(:pm?).and_return(channel == :pm)
      end

      it { is_expected.to eq executable_channels.include?(channel) }
    end
  end
end
