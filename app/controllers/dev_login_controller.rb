class DevLoginController < ApplicationController
  # No auth; dev-only routes are environment-gated

  def by_uid
    uid = params[:uid].to_s
    user = User.find_by(provider: "google_oauth2", uid: uid)
    unless user
      redirect_to root_path, alert: "No user found for UID #{uid}. Run seeds or check the UID."
      return
    end

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid:      user.uid,
      info: {
        email: user.email,
        name:  user.name,
        image: user.image_url
      },
      credentials: { token: "dev-token-#{uid}", refresh_token: "dev-refresh-#{uid}", expires_at: 1.hour.from_now.to_i }
    )
    redirect_to "/auth/google_oauth2"
  end
end
