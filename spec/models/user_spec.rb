require './spec/rails_helper'
require './spec/spec_helper'

describe User do
  describe '#get_by_discord_user' do
    subject { described_class.get_by_discord_user(discord_user) }

    context 'when not exist user' do
      let(:discord_user) { build(:fake_discord_user) }

      it { is_expected.to have_attributes(name: discord_user.display_name, discord_id: discord_user.id.to_s) }
      it { expect { subject }.to change(User, :count).by(1) }
    end

    context 'when exist user' do
      context 'with same name' do
        let(:discord_user) { double(:discord_user, display_name: user.name, id: user.discord_id ) }
        let!(:user) { create(:user) }

        it { is_expected.to have_attributes(name: user.name, discord_id: user.discord_id.to_s) }
        it { expect { subject }.to change(User, :count).by(0) }
      end

      context 'with different name' do
        context 'and have display_name' do
          let(:discord_user) { double(:discord_user, display_name: discord_user_name, id: user.discord_id ) }
          let!(:user) { create(:user) }
          let(:discord_user_name) { Faker::Name.name }

          it { is_expected.to have_attributes(name: discord_user_name, discord_id: user.discord_id.to_s) }
          it { expect { subject }.to change(User, :count).by(0) }
        end

        context 'and not have display_name' do
          let(:discord_user) { double(:discord_user, id: user.discord_id ) }
          let!(:user) { create(:user) }

          it { is_expected.to have_attributes(name: user.name, discord_id: user.discord_id.to_s) }
          it { expect { subject }.to change(User, :count).by(0) }
        end
      end
    end
  end
end
