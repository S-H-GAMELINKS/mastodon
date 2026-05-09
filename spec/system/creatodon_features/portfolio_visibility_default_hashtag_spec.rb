# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon portfolio visibility with default hashtag', :js, :streaming do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'portfolio_user') }

  before { log_in_through_ui(user) }

  after do |example|
    next unless example.exception.nil? || page.has_current_path?(/./, wait: 0)

    visit '/settings/preferences/other'
    if page.has_field?('user_settings_attributes_portfolio_default_hashtag_flag', type: 'checkbox', wait: 2)
      uncheck 'user_settings_attributes_portfolio_default_hashtag_flag', allow_label_click: true
      fill_in 'user_settings_attributes_portfolio_default_hashtag', with: ''
      save_changes
    end
  end

  it 'posts with the default hashtag when the flag is enabled' do
    visit '/settings/preferences/other'
    check 'user_settings_attributes_portfolio_default_hashtag_flag', allow_label_click: true
    fill_in 'user_settings_attributes_portfolio_default_hashtag', with: '#HALO_Infinite'
    save_changes

    visit '/publish'
    choose_visibility('ポートフォリオ')

    expect(page)
      .to have_text('公開範囲が「ポートフォリオ」になっています。')
      .and have_css('textarea[placeholder="どんな作品を投稿する？"]')

    compose_status('HALOやりたい')

    visit "/@#{user.account.username}"

    expect(page)
      .to have_text('HALOやりたい')
      .and have_text('CreatodonFolio')
      .and have_text('HALO_Infinite')
  end

  it 'does not add the default hashtag when the flag is disabled' do
    visit '/settings/preferences/other'
    fill_in 'user_settings_attributes_portfolio_default_hashtag', with: '#HALO_Infinite'
    save_changes

    visit '/publish'
    choose_visibility('ポートフォリオ')

    expect(page)
      .to have_text('公開範囲が「ポートフォリオ」になっています。')
      .and have_css('textarea[placeholder="どんな作品を投稿する？"]')

    compose_status('HALOやりたい')

    visit "/@#{user.account.username}"

    expect(page)
      .to have_text('HALOやりたい')
      .and have_text('CreatodonFolio')
      .and have_no_text('HALO_Infinite')
  end

  it 'does not add the default hashtag when the configured hashtag is empty' do
    visit '/settings/preferences/other'
    check 'user_settings_attributes_portfolio_default_hashtag_flag', allow_label_click: true
    save_changes

    visit '/publish'
    choose_visibility('ポートフォリオ')

    expect(page)
      .to have_text('公開範囲が「ポートフォリオ」になっています。')
      .and have_css('textarea[placeholder="どんな作品を投稿する？"]')

    compose_status('HALOやりたい')

    visit "/@#{user.account.username}"

    expect(page)
      .to have_text('HALOやりたい')
      .and have_text('CreatodonFolio')
      .and have_no_text('HALO_Infinite')
  end
end
