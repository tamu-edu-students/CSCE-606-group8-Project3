require "rails_helper"

RSpec.describe "DevLoginController", type: :request do
  describe "GET /dev_login/:uid" do
    before do
      OmniAuth.config.test_mode = true
    end

    context "when the user exists" do
      let(:uid)   { "agent-uid-123" }
      let!(:user) { create(:user, uid: uid, provider: "google_oauth2", email: "agent@example.com", name: "Agent", image_url: "https://example.com/agent.png") }

      it "sets OmniAuth mock and redirects to provider" do
        get "/dev_login/#{uid}"

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/auth/google_oauth2")

        mock = OmniAuth.config.mock_auth[:google_oauth2]
        expect(mock).to be_present
        expect(mock[:provider]).to eq("google_oauth2")
        expect(mock[:uid]).to eq(uid)

        info = mock[:info]
        expect(info[:email]).to eq(user.email)
        expect(info[:name]).to eq(user.name)
        expect(info[:image]).to eq(user.image_url)

        creds = mock[:credentials]
        expect(creds[:token]).to eq("dev-token-#{uid}")
        expect(creds[:refresh_token]).to eq("dev-refresh-#{uid}")
        expect(creds[:expires_at]).to be_a(Integer)
      end
    end

    context "when the user does not exist" do
      it "redirects to root with an alert" do
        uid = "unknown-user"
        get "/dev_login/#{uid}"

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("No user found for UID #{uid}")
      end
    end
  end
end
