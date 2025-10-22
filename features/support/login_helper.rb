Before('@wip') do
  # Simulate OmniAuth login manually instead of using set_rack_session
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
    provider: 'google_oauth2',
    uid: '12345',
    info: {
      email: 'testuser@example.com',
      name: 'Test User'
    }
  })

  visit '/auth/google_oauth2'
end
