// カスタムテーマの変更テスト
describe('custom theme change test', () => {
  // ログイン処理
  beforeEach(() => {
    cy.visit('/auth/sign_in');
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);
  });

  // 投稿の公開範囲チェック
  it('check visibility', () => {
    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon > .fa').click();

    // 公開範囲をチェック
    cy.contains('ポートフォリオ');
    cy.contains('にゃーん');
  });

  // 投稿の公開範囲「ポートフォリオ」が選択できる
  it('can select portfolio visibility', () => {
    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon > .fa').click();

    // 公開範囲「ポートフォリオ」を選択
    cy.get('[data-index="portfolio"]').click();

    // 公開範囲「ポートフォリオ」を選択した際の表示をチェック
    cy.contains('公開範囲が「ポートフォリオ」になっています。');
    cy.contains('どんな作品を投稿する？');
  });

  // 投稿の公開範囲「ポートフォリオ」で投稿できる
  it('can post portfolio visibility', () => {
    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon > .fa').click();

    // 公開範囲「ポートフォリオ」を選択
    cy.get('[data-index="portfolio"]').click();

    // 公開範囲「ポートフォリオ」を選択した際の表示をチェック
    cy.contains('公開範囲が「ポートフォリオ」になっています。');
    cy.contains('どんな作品を投稿する？');

    // 公開範囲「ポートフォリオ」で投稿
    cy.get('.autosuggest-textarea__textarea').type('HALOやりたい');
    cy.get('.button').click();

    // ホームタイムラインへ遷移し、リロード
    cy.visit('/home');
    cy.reload();

    // タイムライン上に投稿した内容が表示されている
    cy.contains('HALOやりたい');
    cy.contains('CreatodonFolio');
  });

  // 投稿の公開範囲「にゃーん」が選択できる
  it('can select nyan visibility', () => {
    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon > .fa').click();

    // 公開範囲「にゃーん」を選択
    cy.get('[data-index="nyan"]').click();

    // 公開範囲「にゃーん」を選択した際の表示をチェック
    cy.contains('公開範囲が「にゃーん」になっています。');
    cy.contains('どんなことを吐き出したい？');
  });

  // 投稿の公開範囲「にゃーん」で投稿できる
  it('can post nyan visibility', () => {
    // 投稿画面へ遷移
    cy.visit('/publish');

    // 公開範囲を選択
    cy.get('.privacy-dropdown__value-icon > .fa').click();

    // 公開範囲「にゃーん」を選択
    cy.get('[data-index="nyan"]').click();

    // 公開範囲「にゃーん」を選択した際の表示をチェック
    cy.contains('公開範囲が「にゃーん」になっています。');
    cy.contains('どんなことを吐き出したい？');

    // 公開範囲「にゃーん」で投稿
    cy.get('.autosuggest-textarea__textarea').type('HALOやりたい');
    cy.get('.button').click();

    // ホームタイムラインへ遷移し、リロード
    cy.visit('/home');
    cy.reload();

    // タイムライン上に投稿した内容が表示されている
    cy.contains('にゃーん');
  });
});
