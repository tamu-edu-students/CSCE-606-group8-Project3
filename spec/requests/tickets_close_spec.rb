require "rails_helper"

RSpec.describe "Tickets close", type: :request do
  let(:requester) { create(:user, :requester) }
  let(:ticket) { create(:ticket, requester: requester, status: :open) }

  it "requester can close successfully" do
    sign_in(requester)
    patch close_ticket_path(ticket)
    expect(response).to redirect_to(ticket_path(ticket))
    follow_redirect!
    expect(response.body).to include("Ticket resolved successfully")
    ticket.reload
    expect(ticket.status).to eq("resolved")
    expect(ticket.closed_at).to be_present
  end

  it "shows errors when close fails" do
    sign_in(requester)
    allow_any_instance_of(Ticket).to receive(:update) do |obj, *_|
      obj.errors.add(:base, "cannot close")
      false
    end
    patch close_ticket_path(ticket)
    expect(response).to redirect_to(ticket_path(ticket))
    follow_redirect!
    expect(response.body).to include("cannot close")
  end
end
