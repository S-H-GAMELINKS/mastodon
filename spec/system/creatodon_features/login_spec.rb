# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon login' do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'login_user') }

  before { visit '/auth/sign_in?lang=ja' }

  it 'checks the login page url' do
    expect(page).to have_current_path('/auth/sign_in?lang=ja')
    expect(page.current_url).to eq('http://localhost:3000/auth/sign_in?lang=ja')
  end

  it 'shows the login page text' do
    expect(page)
      .to have_text('ログイン')
      .and have_text('メールアドレス')
      .and have_text('パスワード')
  end

  it 'logs in to Creatodon', :js, :streaming do
    log_in_through_ui(user)

    visit '/deck'

    expect(page).to have_css('.app-holder')
  end
end
