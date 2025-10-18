# features/step_definitions/ticket_steps.rb

# Navigation steps
Given("I am on the new ticket page") do
  visit new_ticket_path
end

# Form filling steps
When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

# Button clicking steps
When("I press {string}") do |button|
  click_button button
end

# Page expectation steps
Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

# Custom step for user intent
Then("I should see my new ticket in the ticket list") do
  visit tickets_path
  # For now, just check that the title appears on the index page
  # Later we can refine this to check ticket_number or other unique identifier
  expect(page).to have_content("Login issue")
end

When("I go to the tickets list page") do
  visit tickets_path
end

Then("I should see {string} in the ticket list") do |ticket_title|
  visit tickets_path unless current_path == tickets_path
  expect(page).to have_content(ticket_title)
end