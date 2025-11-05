require 'rails_helper'

RSpec.describe "Ticket attachments", type: :request do
  before(:all) do
    unless ActiveRecord::Base.connection.data_source_exists?('active_storage_blobs') && ActiveRecord::Base.connection.data_source_exists?('active_storage_attachments')
      skip "ActiveStorage tables are not present in the test DB; run migrations to enable attachment tests"
    end
  end
  let(:requester) { create(:user, role: :user) }
  let(:agent) { create(:user, :agent) }
  let(:ticket) { create(:ticket, requester: requester) }

  describe "PATCH /tickets/:id (attachments)" do
    it "allows an agent to upload attachments when editing a ticket" do
      sign_in(agent)

      uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.txt'), 'text/plain')

      patch ticket_path(ticket), params: { ticket: { attachments: [ uploaded ] } }
      ticket.reload

      expect(ticket.attachments).to be_attached
      expect(ticket.attachments.first.filename.to_s).to eq('sample.txt')
      expect(response).to redirect_to(ticket_path(ticket))
    end

    it "does not attach files when a non-staff requester tries to upload" do
      sign_in(requester)

      uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.txt'), 'text/plain')

      patch ticket_path(ticket), params: { ticket: { attachments: [ uploaded ] } }
      ticket.reload

      expect(ticket.attachments.attached?).to be_falsey
    end

    it "allows an agent to remove an existing attachment" do
      # attach an initial file
      sign_in(agent)
      uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.txt'), 'text/plain')
      patch ticket_path(ticket), params: { ticket: { attachments: [ uploaded ] } }
      ticket.reload
      expect(ticket.attachments).to be_attached

      # now remove it
      att_id = ticket.attachments.first.id
      patch ticket_path(ticket), params: { ticket: { remove_attachment_ids: [ att_id ] } }
      ticket.reload
      expect(ticket.attachments.attached?).to be_falsey
    end

    it "prevents a non-staff from removing attachments" do
      # set up attachment as staff
      sign_in(agent)
      uploaded = Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/sample.txt'), 'text/plain')
      patch ticket_path(ticket), params: { ticket: { attachments: [ uploaded ] } }
      ticket.reload
      expect(ticket.attachments).to be_attached

      # now attempt removal as requester
      sign_in(requester)
      att_id = ticket.attachments.first.id
      patch ticket_path(ticket), params: { ticket: { remove_attachment_ids: [ att_id ] } }
      ticket.reload
      # shouldn't be removed because permitted_attributes won't allow this param for requester
      expect(ticket.attachments.attached?).to be_truthy
    end
  end
end
