require 'rails_helper'

RSpec.describe TicketPolicy do
  let(:requester) { FactoryBot.create(:user, role: :requester) }
  let(:agent) { FactoryBot.create(:user, role: :agent) }
  let(:admin) { FactoryBot.create(:user, role: :admin) }
  let(:ticket) { FactoryBot.create(:ticket, requester: requester) }

  subject { described_class.new(user, ticket) }

  context 'when user is requester' do
    let(:user) { requester }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:assign) }

    context 'when ticket is closed' do
      before { ticket.update(status: :closed) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end

  context 'when user is agent' do
    let(:user) { agent }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:assign) }
    it { is_expected.not_to permit_action(:destroy) }
  end

  context 'when user is admin' do
    let(:user) { admin }

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:new) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:assign) }
    it { is_expected.to permit_action(:destroy) }
  end
end
