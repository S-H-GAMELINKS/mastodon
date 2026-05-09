# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon media upload', :attachment_processing, :inline_jobs, :js, :streaming do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'media_user') }

  before do
    log_in_through_ui(user)
    visit '/profile/edit'
    first('header button[title="Add image"], header button[title="Replace image"]', minimum: 1)
  end

  it 'uploads a cover photo from the profile edit UI' do
    first('header button[title="Add image"], header button[title="Replace image"]').click

    first('.dropdown-menu__item button[data-index="0"]').click if page.has_css?('.dropdown-menu__item button[data-index="0"]')

    expect(page).to have_css('.dialog-modal')
    expect(page).to have_css('.dialog-modal__header__title', text: /cover photo|profile photo/i)
    expect(page).to have_button('Browse files')

    find('.dialog-modal input[type="file"]', visible: false).set(file_fixture('header.png'))

    within('.dialog-modal') do
      click_button 'Next'
      click_button 'Done'
    end

    expect(page)
      .to have_no_css('.dialog-modal')
      .and have_css('header img[src]', minimum: 1)
  end
end
