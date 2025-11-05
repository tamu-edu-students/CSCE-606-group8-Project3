require 'rails_helper'

RSpec.describe "Ticket approvals", type: :request do
  let(:requester) { create(:user, role: :user) }
  let(:agent) { create(:user, :agent) }
  let(:ticket) { create(:ticket, requester: requester) }

  describe "PATCH /tickets/:id/approve" do
    it "allows an agent to approve a ticket" do
      sign_in(agent)

      patch approve_ticket_path(ticket)
      ticket.reload

      expect(ticket.approval_status).to eq("approved")
      expect(ticket.approver).to eq(agent)
      expect(ticket.approved_at).to be_present
      expect(response).to redirect_to(tickets_path)
      follow_redirect!
      expect(response.body).to include("Ticket approved")
    end

    it "prevents non-staff from approving the ticket" do
      sign_in(requester)

      expect {
        patch approve_ticket_path(ticket)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end

  describe "PATCH /tickets/:id/reject" do
    it "allows an agent to reject a ticket with a reason" do
      sign_in(agent)

      patch reject_ticket_path(ticket), params: { ticket: { approval_reason: "Not reproducible" } }
      ticket.reload

      expect(ticket.approval_status).to eq("rejected")
      expect(ticket.approver).to eq(agent)
      expect(ticket.approval_reason).to eq("Not reproducible")
      expect(ticket.approved_at).to be_present
      expect(response).to redirect_to(tickets_path)
      follow_redirect!
      expect(response.body).to include("Ticket rejected")
    end

    it "requires a rejection reason" do
      sign_in(agent)

      patch reject_ticket_path(ticket)

      expect(response).to redirect_to(ticket_path(ticket))
      follow_redirect!
      expect(response.body).to include("Rejection reason is required")
    end

    it "prevents non-staff from rejecting the ticket" do
      sign_in(requester)

      expect {
        patch reject_ticket_path(ticket), params: { ticket: { approval_reason: "Nope" } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
