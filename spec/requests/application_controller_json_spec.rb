require "rails_helper"

RSpec.describe "ApplicationController JSON auth responses", type: :request do
  it "returns 401 JSON with error for unauthenticated JSON request and does not set return_to" do
    get users_path, headers: { "ACCEPT" => "application/json" }
    expect(response).to have_http_status(:unauthorized)
    expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
    expect(session[:return_to]).to be_nil
  end

  it "does not set return_to for non-GET HTML request" do
    # non-GET should not store return_to
    post users_path
    expect(response).to redirect_to(login_path)
    expect(session[:return_to]).to eq(root_path)
  end
end
