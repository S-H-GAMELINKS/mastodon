// ログイン周りのE2Eテスト
describe('access to login page', () => {
  beforeEach(() => {
    cy.visit('/auth/sign_in');
  });

  // ログイン画面のURLチェック
  it('url check', () => {
    cy.url().should('include', '/auth/sign_in');
    cy.url().should('eq', 'http://localhost:3000/auth/sign_in');
  });

  // ログイン画面内にあるテキストのチェック
  it('include login page text', () => {
    cy.contains('Login to localhost');
    cy.contains('E-mail address');
    cy.contains('Password');
  });

  // 実際にログイン
  it('login to Creatodon', () => {
    // メールアドレスとパスワードを入力し、ログイン
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);

    // ログイン後の画面で投稿フォームが表示されているのを確認
    cy.contains('投稿');
  });
});
