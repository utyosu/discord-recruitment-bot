require './spec/rails_helper'
require './spec/spec_helper'

describe Channel do
  describe '#get_by_discord_channel' do
    subject { described_class.get_by_discord_channel(channel) }

    context 'when not exist channel' do
      let(:channel) { build(:fake_channel) }

      it { is_expected.to have_attributes(channel_id: channel.id.to_s, name: channel.name) }
    end

    context 'when exist channel' do
      before { described_class.create(channel_id: channel.id, name: channel.name) }

      let(:channel) { build(:fake_channel) }

      it { is_expected.to have_attributes(channel_id: channel.id.to_s, name: channel.name) }
      it { expect { subject }.not_to change(described_class, :count) }
    end
  end
end
