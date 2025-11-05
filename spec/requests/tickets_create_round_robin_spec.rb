require "rails_helper"

RSpec.describe "Ticket create round-robin", type: :request do
  let!(:requester) { create(:user, :requester) }
  let!(:agent1) { create(:user, :agent) }
  let!(:agent2) { create(:user, :agent) }

  before do
    # Enable round robin
    Setting.set("assignment_strategy", "round_robin")
    # Ensure deterministic order
    agent1; agent2
  end

  def ticket_params
    { subject: "S", description: "D", priority: "medium", category: Ticket::CATEGORY_OPTIONS.first }
  end

  it "cycles assignee across staff users using Setting.last_assigned_index" do
    sign_in(requester)

    post tickets_path, params: { ticket: ticket_params }
    t1 = Ticket.order(:id).last
    expect(t1.assignee).to eq(agent1)

    post tickets_path, params: { ticket: ticket_params }
    t2 = Ticket.order(:id).last
    expect(t2.assignee).to eq(agent2)

    post tickets_path, params: { ticket: ticket_params }
    t3 = Ticket.order(:id).last
    expect(t3.assignee).to eq(agent1)
  end
end
