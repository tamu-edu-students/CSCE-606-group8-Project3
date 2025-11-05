require "rails_helper"

RSpec.describe "Ticket assignment flows", type: :request do
  let!(:agent1) { create(:user, :agent) }
  let!(:agent2) { create(:user, :agent) }
  let!(:team_a) { Team.create!(name: "Team A") }
  let!(:team_b) { Team.create!(name: "Team B") }
  let(:ticket) { create(:ticket, team: team_a, assignee: agent1, requester: create(:user)) }

  before do
    team_a.team_memberships.create!(user: agent1, role: :member)
    team_b.team_memberships.create!(user: agent2, role: :member)
  end

  it "agent can change team and keep valid assignee" do
    sign_in(agent1)
    patch assign_ticket_path(ticket), params: { ticket: { team_id: team_a.id, assignee_id: agent1.id } }
    expect(response).to redirect_to(ticket_path(ticket))
    ticket.reload
    expect(ticket.team).to eq(team_a)
    expect(ticket.assignee).to eq(agent1)
  end

  it "changing team without assignee clears invalid assignee for new team" do
    sign_in(agent1)
    # move from A->B without giving assignee; agent1 is not in B so should clear
    patch assign_ticket_path(ticket), params: { ticket: { team_id: team_b.id } }
    expect(response).to redirect_to(ticket_path(ticket))
    ticket.reload
    expect(ticket.team).to eq(team_b)
    expect(ticket.assignee_id).to be_nil
  end

  it "blank values nullify fields" do
    sign_in(agent1)
    patch assign_ticket_path(ticket), params: { ticket: { team_id: "", assignee_id: "" } }
    expect(response).to redirect_to(ticket_path(ticket))
    ticket.reload
    expect(ticket.team_id).to be_nil
    expect(ticket.assignee_id).to be_nil
  end

  it "shows error when no changes provided" do
    sign_in(agent1)
    patch assign_ticket_path(ticket), params: { ticket: {} }
    expect(response).to redirect_to(ticket_path(ticket))
    follow_redirect!
    expect(response.body).to include("No assignment changes provided")
  end
end
