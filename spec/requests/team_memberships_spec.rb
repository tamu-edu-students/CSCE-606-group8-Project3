require "rails_helper"

RSpec.describe "TeamMemberships", type: :request do
  let!(:team) { Team.create!(name: "Dev Team") }
  let!(:member_user) { create(:user, :requester) }
  let!(:admin) { create(:user, :admin) }

  describe "POST /teams/:team_id/team_memberships" do
    it "allows sysadmin to add a member" do
      sign_in(admin)
      expect {
        post team_team_memberships_path(team), params: { team_membership: { user_id: member_user.id, role: "member" } }
      }.to change { team.team_memberships.count }.by(1)
      expect(response).to redirect_to(team_path(team))
      follow_redirect!
      expect(response.body).to include("Member added")
    end

    it "prevents non-sysadmin from adding a member" do
      sign_in(member_user)
      expect {
        post team_team_memberships_path(team), params: { team_membership: { user_id: member_user.id, role: "member" } }
      }.to raise_error(Pundit::NotAuthorizedError)
    end

    it "fails gracefully on invalid (duplicate) membership" do
      sign_in(admin)
      team.team_memberships.create!(user: member_user, role: :member)

      expect {
        post team_team_memberships_path(team), params: { team_membership: { user_id: member_user.id, role: "member" } }
      }.not_to change { team.team_memberships.count }

      expect(response).to redirect_to(team_path(team))
      follow_redirect!
      expect(response.body).to match(/has already been taken|Member added|Member/)
    end
  end

  describe "DELETE /teams/:team_id/team_memberships/:id" do
    it "allows sysadmin to remove a member" do
      sign_in(admin)
      membership = team.team_memberships.create!(user: member_user, role: :member)

      expect {
        delete team_team_membership_path(team, membership)
      }.to change { team.team_memberships.count }.by(-1)

      expect(response).to redirect_to(team_path(team))
      follow_redirect!
      expect(response.body).to include("Member removed")
    end

    it "prevents non-sysadmin from removing a member" do
      membership = team.team_memberships.create!(user: member_user, role: :member)
      sign_in(member_user)

      expect {
        delete team_team_membership_path(team, membership)
      }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
