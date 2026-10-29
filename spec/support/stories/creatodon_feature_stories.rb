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

  # フロントエンドと同じ解決順で翻訳を引く。
  # Crowdin が追いつくまで未訳のキーは英語にフォールバックするため、
  # 日本語訳の有無に関わらず spec が壊れないようにする。
  def frontend_translation(key, locale: 'ja')
    localized = JSON.parse(Rails.root.join('app', 'javascript', 'mastodon', 'locales', "#{locale}.json").read)
    localized[key].presence || frontend_translations(key)
  end

  # 新しい投稿フォームのテキストエリアの id
  def composer_textarea_id
    'composer-text'
  end

  # 投稿フォームのツールバーで最初のメニューボタンが公開範囲の切り替え
  def open_visibility_menu
    within('form[role="dialog"]') do
      first('button[aria-haspopup="menu"]').click
    end
    expect(page).to have_css('[role="menuitemradio"]')
  end

  def choose_visibility(name)
    open_visibility_menu
    find('[role="menuitemradio"]', text: name).click

    # メニューは選択後も開いたままなので、テキストエリアをクリックして閉じる
    find_field(composer_textarea_id).click
    expect(page).to have_no_css('[role="menuitemradio"]')
  end

  def compose_status(text)
    # 画像添付時は浮いている投稿パネルも開いて投稿フォームが2つになるため、最初のフォームで操作する
    within(first('form[role="dialog"]')) do
      fill_in composer_textarea_id, with: text
      click_on frontend_translation('compose.publish')
    end
  end

  def latest_status
    first('.status__wrapper > .status, .status__wrapper .status', minimum: 1)
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
