// 公開範囲「ポートフォリオ」でのデフォルトハッシュタグ設定のテスト
describe('portfolio visibility default hashtag setting spec', () => {
  // ログイン処理
  beforeEach(() => {
    cy.visit('/auth/sign_in');
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);
  });

  // 公開範囲「ポートフォリオ」のデフォルトハッシュタグ設定をクリア
  afterEach(() => {
    // 設定画面へ遷移
    cy.visit('/settings/preferences/other');

    // 公開範囲「ポートフォリオ」でデフォルトハッシュタグを利用するフラグをOn
    cy.get(
      '#user_settings_attributes_portfolio_default_hashtag_flag',
    ).uncheck();

    // 公開範囲「ポートフォリオ」で利用するハッシュタグを空に
    cy.get('#user_settings_attributes_portfolio_default_hashtag').clear();

    // 変更した設定を保存
    cy.get('.btn').click();
  });

  // 投稿の公開範囲「ポートフォリオ」にデフォルトハッシュタグを付与して投稿できる
  it('can post portfolio visibility with default hashtag', () => {
    // 設定画面へ遷移
    cy.visit('/settings/preferences/other');

    // 公開範囲「ポートフォリオ」でデフォルトハッシュタグを利用するフラグをOn
    cy.get('#user_settings_attributes_portfolio_default_hashtag_flag').check();

    // 公開範囲「ポートフォリオ」で利用するハッシュタグを設定
    cy.get('#user_settings_attributes_portfolio_default_hashtag').type(
      '#HALO_Infinite',
    );

    // 変更した設定を保存
    cy.get('.btn').click();

    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon').click();

    // 公開範囲「ポートフォリオ」を選択
    cy.get('[data-index="portfolio"]').click();

    // 公開範囲「ポートフォリオ」を選択した際の表示をチェック
    cy.contains('公開範囲が「ポートフォリオ」になっています。');
    cy.contains('どんな作品を投稿する？');

    // 公開範囲「ポートフォリオ」で投稿
    cy.get('.autosuggest-textarea__textarea').type('HALOやりたい');
    cy.get('button.button.button--block').click();

    // ホームタイムラインへ遷移し、リロード
    cy.visit('/deck/public/local');
    cy.reload();

    // タイムライン上に投稿した内容が表示されている
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('HALOやりたい');
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('CreatodonFolio');
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('HALO_Infinite');
  });

  // フラグをOffにした場合はデフォルトハッシュタグが付与されない
  it('can post portfolio visibility but default hashtag not exist(flag off)', () => {
    // 設定画面へ遷移
    cy.visit('/settings/preferences/other');

    // 公開範囲「ポートフォリオ」で利用するハッシュタグを設定
    cy.get('#user_settings_attributes_portfolio_default_hashtag').type(
      '#HALO_Infinite',
    );

    // 変更した設定を保存
    cy.get('.btn').click();

    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon').click();

    // 公開範囲「ポートフォリオ」を選択
    cy.get('[data-index="portfolio"]').click();

    // 公開範囲「ポートフォリオ」を選択した際の表示をチェック
    cy.contains('公開範囲が「ポートフォリオ」になっています。');
    cy.contains('どんな作品を投稿する？');

    // 公開範囲「ポートフォリオ」で投稿
    cy.get('.autosuggest-textarea__textarea').type('HALOやりたい');
    cy.get('button.button.button--block').click();

    // ホームタイムラインへ遷移し、リロード
    cy.visit('/deck/public/local');
    cy.reload();

    // タイムライン上に投稿した内容が表示されている
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('HALOやりたい');
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('CreatodonFolio');

    // デフォルトハッシュタグは表示されない
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).should('not.include.text', 'HALO_Infinite');
  });

  // フラグをOnにしてもデフォルトハッシュタグが設定されていない場合は表示されない
  it('can post portfolio visibility but default hashtag not exist(default hashtag is empty)', () => {
    // 設定画面へ遷移
    cy.visit('/settings/preferences/other');

    // 公開範囲「ポートフォリオ」でデフォルトハッシュタグを利用するフラグをOn
    cy.get('#user_settings_attributes_portfolio_default_hashtag_flag').check();

    // 変更した設定を保存
    cy.get('.btn').click();

    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon').click();

    // 公開範囲「ポートフォリオ」を選択
    cy.get('[data-index="portfolio"]').click();

    // 公開範囲「ポートフォリオ」を選択した際の表示をチェック
    cy.contains('公開範囲が「ポートフォリオ」になっています。');
    cy.contains('どんな作品を投稿する？');

    // 公開範囲「ポートフォリオ」で投稿
    cy.get('.autosuggest-textarea__textarea').type('HALOやりたい');
    cy.get('button.button.button--block').click();

    // ホームタイムラインへ遷移し、リロード
    cy.visit('/deck/public/local');
    cy.reload();

    // タイムライン上に投稿した内容が表示されている
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('HALOやりたい');
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).contains('CreatodonFolio');

    // デフォルトハッシュタグは表示されない
    cy.get(
      '[aria-posinset="1"] > [tabindex="-1"] > .status__wrapper > .status',
    ).should('not.include.text', 'HALO_Infinite');
  });
});
