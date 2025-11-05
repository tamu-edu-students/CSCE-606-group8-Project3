require "rails_helper"

RSpec.describe "Tickets show filtering", type: :request do
  let(:requester) { create(:user, :requester) }
  let(:other_user) { create(:user, :requester) }
  let(:agent) { create(:user, :agent) }
  let(:ticket) { create(:ticket, requester: requester) }

  before do
    sign_in(requester)
    Comment.create!(ticket: ticket, author: agent, body: "public comment", visibility: :public)
    Comment.create!(ticket: ticket, author: agent, body: "internal note", visibility: :internal)
  end

  it "requester sees only public comments" do
    get ticket_path(ticket)
    expect(response.body).to include("public comment")
    expect(response.body).not_to include("internal note")
  end

  it "non-requester, non-agent sees no comments" do
    sign_in(other_user)
    expect {
      get ticket_path(ticket)
    }.to raise_error(Pundit::NotAuthorizedError)
  end
end
