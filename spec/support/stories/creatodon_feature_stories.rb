# frozen_string_literal: true

module CreatodonFeatureStories
  def onboard_user(user)
    Web::Setting.where(user: user).first_or_initialize(user: user).update!(data: { introductionVersion: 2018_12_16_044202 })
    user
  end

  def create_onboarded_user(username:, locale: 'ja')
    onboard_user(Fabricate(:user, locale: locale, account: Fabricate(:account, username: username)))
  end

  def log_in_through_ui(user, lang: 'ja')
    visit "/auth/sign_in?lang=#{lang}"

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_on I18n.t('auth.login', locale: lang)

    expect(page).to have_css('.app-holder')
  end

  def save_changes
    within('form') { find("button[type='submit'], input[type='submit']").click }
  end

  def open_visibility_modal
    first('.compose-form__dropdowns > .dropdown-button').click
    expect(page).to have_css('.visibility-modal')
  end

  def choose_visibility(name)
    open_visibility_modal
    within('.visibility-modal') do
      first('.visibility-dropdown__button').click
    end

    find("li[role='option'][data-index='#{visibility_value(name)}']", wait: 10).click

    within('.visibility-modal') do
      click_on '保存'
    end
  end

  def compose_status(text)
    find('.autosuggest-textarea__textarea').set(text)
    find('.compose-form__submit > .button').click
  end

  def latest_status
    first('.status__wrapper > .status, .status__wrapper .status', minimum: 1)
  end

  def visibility_value(name)
    {
      'ポートフォリオ' => 'portfolio',
      'にゃーん' => 'nyan',
    }.fetch(name, name)
  end

  def draw_line_on_canvas(from_x:, from_y:, to_x:, to_y:)
    Capybara.current_session.driver.with_playwright_page do |playwright_page|
      box = playwright_page.locator('#react-sketch-canvas__canvas-background').bounding_box
      raise 'Canvas bounding box not found' if box.nil?

      start_x = box['x'] + from_x
      start_y = box['y'] + from_y
      end_x = box['x'] + to_x
      end_y = box['y'] + to_y

      playwright_page.mouse.move(start_x, start_y)
      playwright_page.mouse.down
      playwright_page.mouse.move(end_x, end_y)
      playwright_page.mouse.up
    end
  end
end
