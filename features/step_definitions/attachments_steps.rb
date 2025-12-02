When("I attach the file {string}") do |path|
  full = Rails.root.join(path)
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
  if page.has_button?('Update')
    click_button 'Update'
  elsif page.has_button?('Save')
    click_button 'Save'
  else
    click_button 'Submit'
  end
end

When("I remove the attachment named {string}") do |filename|
  within(".attachment-manage-list") do
    # Find the row/div for the attachment with this filename
    item = find(".attachment-manage-item", text: filename)

    # Find the checkbox inside it (visible or not) and tick it
    checkbox = item.find('input[type="checkbox"]', visible: :all)
    checkbox.set(true)
  end

    # Support multiple attachments-list renderings used by the app
    if page.has_css?('.attachment-manage-list')
      within('.attachment-manage-list') do
        item = find('.attachment-manage-item', text: filename)
        begin
          checkbox = item.find('input[type="checkbox"]', visible: true)
        rescue Capybara::ElementNotFound
          checkbox = item.find('input[type="checkbox"]', visible: false)
        end
        checkbox.set(true)
      end
    elsif page.has_css?('.attachment-list')
      within('.attachment-list') do
        li = find('li', text: filename)
        begin
          checkbox = li.find('input[type="checkbox"]', visible: true)
        rescue Capybara::ElementNotFound
          checkbox = li.find('input[type="checkbox"]', visible: false)
        end
        checkbox.set(true)
      end
    else
      item = find('div,li', text: filename, match: :first)
      begin
        checkbox = item.find('input[type="checkbox"]', visible: true)
      rescue Capybara::ElementNotFound
        checkbox = item.find('input[type="checkbox"]', visible: false)
      end
      checkbox.set(true)
    end
end

Then("I should be on the ticket page for {string}") do |ticket_title|
  ticket = Ticket.find_by(subject: ticket_title)
  expect(current_path).to eq(ticket_path(ticket))
end
