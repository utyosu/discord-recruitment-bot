require './spec/rails_helper'
require './spec/spec_helper'

describe 'analysises' do
  describe '.index' do
    subject { page }

    let!(:user) { create(:user) }
    let!(:user_status) { create(:user_status, user: user, channel: channel, created_at: Time.zone.parse('2020-01-01 12:00')) }
    let!(:channel) { create(:channel) }

    before { visit analysises_path(params) }

    context 'with no params' do
      let(:params) { {} }

      it { is_expected.to have_content 'Analysis' }
    end

    context 'with params' do
      let(:params) do
        {
          start_date: '2020-01-01',
          end_date: '2020-01-01',
        }
      end

      it { is_expected.to have_content channel.name }
    end
  end
end
