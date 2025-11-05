require 'rails_helper'

RSpec.describe "tickets/new", type: :view do
  before(:each) do
    assign(:ticket, Ticket.new(
      subject: "MyString",
      description: "MyText",
      priority: :low
    ))
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

  it "renders new ticket form" do
    render

    assert_select "form[action=?][method=?]", tickets_path, "post" do
      assert_select "input[name=?]", "ticket[subject]"

      assert_select "textarea[name=?]", "ticket[description]"
    end
  end
end
