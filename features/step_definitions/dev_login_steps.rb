# frozen_string_literal: true

Given("a Google user exists with uid {string}, email {string}, name {string}, role {string}") do |uid, email, name, role|
  User.create!(
    provider: "google_oauth2",
    uid: uid,
    email: email,
    name: name,
    image_url: "https://example.com/#{uid}.png",
    role: role
  )
end

When("I visit the dev login path for uid {string}") do |uid|
  visit "/dev_login/#{uid}"
end

Then("I should be on the home page") do
  expect(page).to have_current_path(root_path)
end

Then("I should see the dev login message {string}") do |text|
  expect(page).to have_content(text)
end
