require 'rails_helper'

RSpec.describe "tickets/edit", type: :view do
  let(:requester) { FactoryBot.create(:user, :requester) }
  let(:ticket) do
    create(
      :ticket,
      subject: "MyString",
      description: "MyText",
      priority: :low,
      requester: requester,
      status: :in_progress
    )
  end

  before(:each) do
    assign(:ticket, ticket)
    policy_double = instance_double(TicketPolicy, change_status?: false)
    view.singleton_class.send(:define_method, :policy) do |record|
      case record
      when Ticket
        policy_double
      else
        raise ArgumentError, "Unhandled policy lookup for #{record.inspect}"
      end
    end
  end

  it "renders the edit ticket form" do
    render

    assert_select "form[action=?][method=?]", ticket_path(ticket), "post" do
      assert_select "input[name=?]", "ticket[subject]"

      assert_select "textarea[name=?]", "ticket[description]"
    end
  end
end
