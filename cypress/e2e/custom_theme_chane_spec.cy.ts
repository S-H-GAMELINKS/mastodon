// カスタムテーマの変更テスト
describe('custom theme change test', () => {
  // ログイン処理
  beforeEach(() => {
    cy.visit('/auth/sign_in');
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);
  });

  // デフォルトのテーマに変更
  it('change default theme', () => {
    cy.visit('/settings/preferences/appearance');
    cy.get('#user_settings_attributes_theme').select('default');
    cy.get('.btn').click();
    cy.visit('/home');
  });

  // 「琥珀の意味」のカスタムテーマに変更
  it('change mean of amber theme', () => {
    cy.visit('/settings/preferences/appearance');
    cy.get('#user_settings_attributes_theme').select('mean-of-amber');
    cy.get('.btn').click();
    cy.visit('/home');
  });

  // 「Twitter」のカスタムテーマに変更
  it('change twitetr theme', () => {
    cy.visit('/settings/preferences/appearance');
    cy.get('#user_settings_attributes_theme').select('twitter');
    cy.get('.btn').click();
    cy.visit('/home');
  });
});
