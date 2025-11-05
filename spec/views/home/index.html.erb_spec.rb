require 'rails_helper'

RSpec.describe "home/index.html.erb", type: :view do
  it 'renders the welcome heading' do
    render
    expect(rendered).to include('Welcome')
  end
end
