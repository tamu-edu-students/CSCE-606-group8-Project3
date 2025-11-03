require "rails_helper"

RSpec.describe TeamMembershipPolicy do
  subject(:policy) { described_class }

  let(:team) { Team.create!(name: "QA") }
  let(:user) { create(:user, :requester) }
  let(:admin) { create(:user, :admin) }

  describe "permissions" do
    it "allows sysadmin to create/destroy" do
      p = policy.new(admin, TeamMembership.new(team: team))
      expect(p.create?).to be true
      expect(p.destroy?).to be true
      expect(p.update?).to be true
    end

    it "denies non-sysadmin" do
      p = policy.new(user, TeamMembership.new(team: team))
      expect(p.create?).to be false
      expect(p.destroy?).to be false
      expect(p.update?).to be false
    end
  end

  describe "permitted_attributes" do
    it "returns [:user_id, :role] for sysadmin" do
      p = policy.new(admin, TeamMembership.new(team: team))
      expect(p.permitted_attributes).to match_array([:user_id, :role])
    end

    it "returns [] for non-sysadmin" do
      p = policy.new(user, TeamMembership.new(team: team))
      expect(p.permitted_attributes).to eq([])
    end
  end
end
