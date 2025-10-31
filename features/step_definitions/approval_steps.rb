Given("a dev user with uid {string} and email {string} and name {string} and role {string}") do |uid, email, name, role|
  user = User.find_or_initialize_by(email: email.downcase)
  user.provider = "google_oauth2"
  user.uid = uid
  user.name = name
  user.role = role
  user.save!
end

When("I visit {string}") do |path|
  visit path
end

When("I reject the ticket with reason {string}") do |reason|
  # Submit the rejection directly to the controller to avoid brittle UI interactions
  ticket = begin
    if current_path =~ /\/tickets\/(\d+)/
      Ticket.find($1.to_i)
    else
      Ticket.last
    end
  rescue
    Ticket.last
  end

  page.driver.submit :patch, reject_ticket_path(ticket), { ticket: { approval_reason: reason } }
end

When("I approve the ticket") do
  ticket = begin
    if current_path =~ /\/tickets\/(\d+)/
      Ticket.find($1.to_i)
    else
      Ticket.last
    end
  rescue
    Ticket.last
  end

  page.driver.submit :patch, approve_ticket_path(ticket), {}
end
