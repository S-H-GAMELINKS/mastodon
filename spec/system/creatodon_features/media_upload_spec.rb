# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon media upload', :attachment_processing, :inline_jobs, :js, :streaming do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'media_user') }

  before do
    log_in_through_ui(user)
    visit '/profile/edit'
    first(:button, 'Add image', minimum: 1)
  end

  it 'uploads a cover photo from the profile edit UI' do
    # 新しいユーザーは画像未設定なので「Add image」ボタン (最初がヘッダー画像)
    first(:button, 'Add image').click

    expect(page).to have_css('.dialog-modal')
    expect(page).to have_css('.dialog-modal__header__title', text: /cover photo|profile photo/i)
    expect(page).to have_button('Browse files')

    find('.dialog-modal input[type="file"]', visible: :all).set(file_fixture('header.png'))

    within('.dialog-modal') do
      click_button 'Next'
      click_button 'Done'
    end

    expect(page)
      .to have_no_css('.dialog-modal')
      .and have_css('header img[src]', minimum: 1)
  end
end
