// ログイン周りのE2Eテスト
describe('access to login page', () => {
  beforeEach(() => {
    cy.visit('/auth/sign_in?lang=ja');
  });

  // ログイン画面のURLチェック
  it('url check', () => {
    cy.url().should('include', '/auth/sign_in');
    cy.url().should('eq', 'http://localhost:3000/auth/sign_in?lang=ja');
  });

  // ログイン画面内にあるテキストのチェック
  it('include login page text', () => {
    cy.contains('ログイン');
    cy.contains('メールアドレス');
    cy.contains('パスワード');
  });

  // 実際にログイン
  it('login to Creatodon', () => {
    // メールアドレスとパスワードを入力し、ログイン
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);

    // ログイン後の画面に/deckへ移動できることを確認
    cy.visit('/deck');
  });
});
