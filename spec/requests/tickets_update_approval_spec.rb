require "rails_helper"

RSpec.describe "Ticket update approval branches", type: :request do
  let(:requester) { create(:user, :requester) }
  let(:agent) { create(:user, :agent) }
  let(:ticket) { create(:ticket, requester: requester) }

  before { sign_in(agent) }

  describe "PATCH /tickets/:id (approval approved)" do
    it "approves and redirects" do
      patch ticket_path(ticket), params: { ticket: { approval_status: "approved" } }
      expect(response).to redirect_to(ticket_path(ticket))
      follow_redirect!
      expect(response.body).to include("successfully updated")
      ticket.reload
      expect(ticket.approval_status).to eq("approved")
      expect(ticket.approver).to eq(agent)
    end

    it "rescues when approve! raises" do
      allow_any_instance_of(Ticket).to receive(:approve!).and_raise("Boom")
      patch ticket_path(ticket), params: { ticket: { approval_status: "approved" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Could not approve ticket")
    end
  end

  describe "PATCH /tickets/:id (approval rejected)" do
    it "requires a reason" do
      patch ticket_path(ticket), params: { ticket: { approval_status: "rejected" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Reject reason cannot be blank")
    end

    it "rejects with reason" do
      patch ticket_path(ticket), params: { ticket: { approval_status: "rejected", approval_reason: "Not valid" } }
      expect(response).to redirect_to(ticket_path(ticket))
      follow_redirect!
      expect(response.body).to include("successfully updated")
      ticket.reload
      expect(ticket.approval_status).to eq("rejected")
      expect(ticket.approval_reason).to eq("Not valid")
      expect(ticket.approver).to eq(agent)
    end

    it "rescues when reject! raises" do
      allow_any_instance_of(Ticket).to receive(:reject!).and_raise("Nope")
      patch ticket_path(ticket), params: { ticket: { approval_status: "rejected", approval_reason: "x" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Could not reject ticket")
    end
  end

  describe "PATCH /tickets/:id (approval pending)" do
    it "resets approval fields and redirects" do
      ticket.update!(approval_status: :approved, approver: agent, approved_at: Time.current, approval_reason: "done")
      patch ticket_path(ticket), params: { ticket: { approval_status: "pending" } }
      expect(response).to redirect_to(ticket_path(ticket))
      follow_redirect!
      expect(response.body).to include("successfully updated")
      ticket.reload
      expect(ticket.approval_status).to eq("pending")
      expect(ticket.approver).to be_nil
      expect(ticket.approval_reason).to be_nil
    end
  end
end
