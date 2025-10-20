require 'rails_helper'

RSpec.describe "Tickets", type: :request do
  let(:requester) { FactoryBot.create(:user, role: :requester) }
  let(:agent) { FactoryBot.create(:user, role: :agent) }
  let(:admin) { FactoryBot.create(:user, role: :admin) }

  describe "POST /tickets/:id/assign" do
    let(:ticket) { FactoryBot.create(:ticket, requester: requester) }

    context 'when user is an agent' do
      before { sign_in agent }

      it 'assigns the ticket to the selected agent' do
        post assign_ticket_path(ticket), params: { agent_id: agent.id }
        ticket.reload
        expect(ticket.assignee).to eq(agent)
      end

      it 'redirects to the ticket show page' do
        post assign_ticket_path(ticket), params: { agent_id: agent.id }
        expect(response).to redirect_to(ticket)
      end
    end

    context 'when user is not authorized' do
      before { sign_in requester }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          post assign_ticket_path(ticket), params: { agent_id: agent.id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe "POST /tickets" do
    context 'when auto round-robin is enabled' do
      before do
        Setting.set('assignment_strategy', 'round_robin')
        sign_in requester
      end

      it 'assigns ticket to next agent in rotation' do
        agent1 = FactoryBot.create(:user, role: :agent, name: 'Agent 1')
        agent2 = FactoryBot.create(:user, role: :agent, name: 'Agent 2')

        post tickets_path, params: { ticket: { subject: 'Test', description: 'Test desc', priority: 'normal' } }
        ticket = Ticket.last
        expect(ticket.assignee).to eq(agent1)

        post tickets_path, params: { ticket: { subject: 'Test2', description: 'Test desc2', priority: 'normal' } }
        ticket2 = Ticket.last
        expect(ticket2.assignee).to eq(agent2)
      end
    end

    context 'when auto round-robin is disabled' do
      before do
        Setting.set('assignment_strategy', 'manual')
        sign_in requester
      end

      it 'does not assign ticket automatically' do
        post tickets_path, params: { ticket: { subject: 'Test', description: 'Test desc', priority: 'normal' } }
        ticket = Ticket.last
        expect(ticket.assignee).to be_nil
      end
    end
  end
end
