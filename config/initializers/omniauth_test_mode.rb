if Rails.env.test? || ENV["OMNIAUTH_TEST_MODE"] == "true"
  OmniAuth.config.test_mode = true

  # Safe default; we’ll overwrite per-user in DevLoginController or specs
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: "google_oauth2",
    uid:      "dummy.requester.001",
    info: {
      email: "dummy.requester@example.com",
      name:  "Dummy Requester",
      image: "https://example.com/requester.png"
    },
    credentials: {
      token: "fake-token",
      refresh_token: "fake-refresh",
      expires_at: 1.hour.from_now.to_i
    }
  )
end
