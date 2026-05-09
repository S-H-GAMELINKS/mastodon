# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon featured tag timeline', :js do
  include CreatodonFeatureStories

  let(:viewer) { create_onboarded_user(username: 'viewer_user', locale: 'ja') }
  let(:account) { Fabricate(:account, username: 'halo_user') }
  let!(:tag) { Tag.find_or_create_by!(name: 'HALO') }
  let!(:featured_tag) { Fabricate(:featured_tag, account: account, tag: tag, name: 'HALO') }
  let!(:status) { Fabricate(:status, account: account, text: 'HALO is awesome #HALO') }

  before do
    status.tags << tag
    featured_tag.increment(status.created_at)
  end

  it 'checks the tagged timeline url' do
    visit "/@#{account.username}/tagged/HALO"

    expect(page).to have_current_path("/@#{account.username}/tagged/HALO")
    expect(page.current_url).to eq("http://localhost:3000/@#{account.username}/tagged/HALO")
  end

  it 'shows the featured tag timeline on the account page' do
    skip 'Anonymous account page currently resolves to 404 in the SPA route; original Cypress suite was skipped as well'

    visit account_path(account.username)

    expect(page).to have_css(featured_tag_selector, text: /HALO/)
  end

  it 'shows the featured tag timeline after login', :streaming do
    log_in_through_ui(viewer)

    visit "/@#{account.username}"
    expect(page).to have_css(featured_tag_selector, text: /HALO/)

    visit "/@#{account.username}/tagged/HALO"
    expect(page).to have_css(featured_tag_selector, text: /HALO/)
  end

  def featured_tag_selector
    '.feature_tag_timeline, button[data-name="HALO"]'
  end
end
