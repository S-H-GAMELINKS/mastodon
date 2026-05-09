# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Creatodon custom theme change' do
  include CreatodonFeatureStories

  let(:user) { create_onboarded_user(username: 'theme_user') }

  before { sign_in user }

  it 'changes the theme to default' do
    user.settings['theme'] = 'twitter'
    user.save!

    visit settings_preferences_appearance_path

    select_theme('default')

    expect { save_changes }
      .to change { user.reload.settings['theme'] }.to('default')

    visit '/home'

    expect(page).to have_current_path('/home')
  end

  it 'changes the theme to mean-of-amber' do
    visit settings_preferences_appearance_path

    select_theme('mean-of-amber')

    expect { save_changes }
      .to change { user.reload.settings['theme'] }.to('mean-of-amber')

    visit '/home'

    expect(page).to have_current_path('/home')
  end

  it 'changes the theme to twitter' do
    visit settings_preferences_appearance_path

    select_theme('twitter')

    expect { save_changes }
      .to change { user.reload.settings['theme'] }.to('twitter')

    visit '/home'

    expect(page).to have_current_path('/home')
  end

  def select_theme(value)
    find_by_id('user_settings_attributes_theme').find("option[value='#{value}']").select_option
  end
end
