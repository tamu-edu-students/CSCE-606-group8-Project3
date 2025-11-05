require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:requester) { User.create!(provider: 'seed', uid: SecureRandom.uuid, email: 'req@example.com', role: 'user', name: 'Requester') }
  let(:staff) { User.create!(provider: 'google_oauth2', uid: 'agent-test', email: 'agent@example.com', role: 'staff', name: 'Agent') }

  it 'can be approved by staff' do
    ticket = Ticket.create!(subject: 'T', description: 'D', category: Ticket::CATEGORY_OPTIONS.first, requester: requester)
    expect(ticket.approval_status).to eq('pending')
    ticket.approve!(staff)
    expect(ticket.approval_status).to eq('approved')
    expect(ticket.approver).to eq(staff)
    expect(ticket.approved_at).not_to be_nil
  end

  it 'can be rejected by staff with a reason' do
    ticket = Ticket.create!(subject: 'T2', description: 'D2', category: Ticket::CATEGORY_OPTIONS.first, requester: requester)
    ticket.reject!(staff, 'Not valid')
    expect(ticket.approval_status).to eq('rejected')
    expect(ticket.approval_reason).to eq('Not valid')
    expect(ticket.approver).to eq(staff)
  end
end
require 'rails_helper'

RSpec.describe Ticket, type: :model do
  let(:requester) { FactoryBot.create(:user, role: :user) }
  let(:agent) { FactoryBot.create(:user, role: :staff) }
  let(:ticket) { FactoryBot.create(:ticket, requester: requester, assignee: agent) }

  describe 'associations' do
    it { should belong_to(:requester).class_name('User') }
    it { should belong_to(:assignee).class_name('User').optional }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(open: 0, in_progress: 1, on_hold: 2, resolved: 3) }
    it { should define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2) }
  end

  describe 'validations' do
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }
    it { should validate_presence_of(:category) }
    it { should validate_inclusion_of(:category).in_array(Ticket::CATEGORY_OPTIONS) }
    it { should validate_presence_of(:requester) }
  end

  describe 'defaults' do
    it 'defaults priority to medium' do
      expect(Ticket.new.priority).to eq("medium")
    end
  end

  describe '#track_resolution_timestamp' do
    context 'when status changes to resolved' do
      it 'sets closed_at timestamp' do
        ticket.update(status: :resolved)
        expect(ticket.closed_at).to be_present
      end
    end

    context 'when status changes from resolved to another' do
      it 'clears closed_at timestamp' do
        ticket.update(status: :resolved)
        ticket.update(status: :open)
        ticket.reload
        expect(ticket.closed_at).to be_nil
      end
    end
  end
end
