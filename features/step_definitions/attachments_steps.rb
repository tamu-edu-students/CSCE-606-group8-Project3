When("I attach the file {string}") do |path|
  full = Rails.root.join(path)
  # try a few ways to find the file input to be resilient across drivers
  begin
    attach_file('Attachments (staff only)', full)
  rescue Capybara::ElementNotFound
    begin
      attach_file('ticket[attachments][]', full)
    rescue Capybara::ElementNotFound
      # fallback: find the first file input and attach
      input = find('input[type="file"]', match: :first, visible: false)
      attach_file(input[:id] || input[:name], full, make_visible: true)
    end
  end
end

When("I submit the ticket form") do
  # the update button text varies; try common values
  if page.has_button?('Update')
    click_button 'Update'
  elsif page.has_button?('Save')
    click_button 'Save'
  else
    click_button 'Submit'
  end
end

When("I remove the attachment named {string}") do |filename|
  # find the list item that contains the filename and check the remove checkbox inside it
  within('.existing-attachments') do
    li = find('li', text: filename)
    # checkbox may be hidden depending on styling; try visible then fallback
    begin
      checkbox = li.find('input[type="checkbox"]', visible: true)
    rescue Capybara::ElementNotFound
      checkbox = li.find('input[type="checkbox"]', visible: false)
    end
    checkbox.set(true)
  end
end

Then("I should be on the ticket page for {string}") do |ticket_title|
  ticket = Ticket.find_by(subject: ticket_title)
  expect(current_path).to eq(ticket_path(ticket))
end
