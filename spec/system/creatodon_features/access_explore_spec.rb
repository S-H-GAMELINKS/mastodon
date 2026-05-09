# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon access explore' do
  it 'checks the explore url' do
    visit '/explore'

    expect(page).to have_current_path('/explore')
    expect(page.current_url).to eq('http://localhost:3000/explore')
  end
end
