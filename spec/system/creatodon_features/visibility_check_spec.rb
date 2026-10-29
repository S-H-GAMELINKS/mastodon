# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon visibility check', :js, :streaming do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'visibility_user') }

  before do
    log_in_through_ui(user)
    visit '/publish'
    find_field(composer_textarea_id)
  end

  it 'shows portfolio and nyan in the visibility list' do
    open_visibility_menu

    expect(page)
      .to have_css('[role="menuitemradio"]', text: 'ポートフォリオ')
      .and have_css('[role="menuitemradio"]', text: 'にゃーん')
  end

  it 'selects portfolio visibility' do
    choose_visibility('ポートフォリオ')

    expect(page)
      .to have_text('公開範囲が「ポートフォリオ」になっています。')
      .and have_field(composer_textarea_id, placeholder: 'どんな作品を投稿する？')
  end

  it 'posts with portfolio visibility' do
    choose_visibility('ポートフォリオ')

    expect(page)
      .to have_text('公開範囲が「ポートフォリオ」になっています。')
      .and have_field(composer_textarea_id, placeholder: 'どんな作品を投稿する？')

    compose_status('HALOやりたい')

    visit "/@#{user.account.username}"

    expect(page)
      .to have_text('HALOやりたい')
      .and have_text('CreatodonFolio')
  end

  it 'selects nyan visibility' do
    choose_visibility('にゃーん')

    expect(page)
      .to have_text('公開範囲が「にゃーん」になっています。')
      .and have_field(composer_textarea_id, placeholder: 'どんなことを吐き出したい？')
  end

  it 'posts with nyan visibility' do
    choose_visibility('にゃーん')

    expect(page)
      .to have_text('公開範囲が「にゃーん」になっています。')
      .and have_field(composer_textarea_id, placeholder: 'どんなことを吐き出したい？')

    compose_status('HALOやりたい')

    visit "/@#{user.account.username}"

    expect(page).to have_text('にゃーん')
  end

  it 'posts with nyan visibility and content warning' do
    choose_visibility('にゃーん')

    expect(page)
      .to have_text('公開範囲が「にゃーん」になっています。')
      .and have_field(composer_textarea_id, placeholder: 'どんなことを吐き出したい？')

    # Alt+X で閲覧注意 (CW) 欄を表示する
    find_field(composer_textarea_id).send_keys([:alt, 'x'])
    fill_in frontend_translation('compose.sensitive.text'), with: 'CW'

    compose_status('HALOやりたい')

    visit "/@#{user.account.username}"

    expect(page)
      .to have_text('にゃーん')
      .and have_text(frontend_translation('content_warning.show_post'))
  end
end
