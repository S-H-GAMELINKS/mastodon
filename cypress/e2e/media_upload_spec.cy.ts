// 画像投稿周りのE2Eテスト
describe('media upload test', () => {
  // ログイン処理
  beforeEach(() => {
    cy.visit('/auth/sign_in');
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);
  });

  // アカウントのヘッダーとアイコン画像の変更
  it('can post with image', () => {
    cy.visit('/settings/profile');

    cy.get('#account_header').attachFile('header.png');
    cy.get('#account_avatar').attachFile('icon.png');

    cy.get('.button').click();
  });
});
