// 注目のハッシュタグタイムライン機能のE2Eテスト
describe('feature tag timeline', () => {
  // URLのチェック
  it('url check', () => {
    cy.visit('/@S_H_/tagged/HALO');
    cy.url().should('include', '/@S_H_/tagged/HALO');
    cy.url().should('eq', 'http://localhost:3000/@S_H_/tagged/HALO');
  });

  // アカウントの詳細画面で注目のハッシュタグタイムラインが項目としてあるかをチェック
  it('include feature tag timeline', () => {
    cy.visit('/@S_H_');
    cy.get('.feature_tag_timeline');
    cy.contains('HALO');
  });

  // ログイン後にアカウントの詳細画面で注目のハッシュタグタイムラインが項目としてあるかをチェック
  it('login to Creatodon and my feature tag timeline exist', () => {
    // ログイン処理
    cy.visit('/auth/sign_in');
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);

    // アカウントの詳細画面で注目のハッシュタグタイムラインが項目としてあるかをチェック
    cy.visit('/@S_H_');
    cy.get('.feature_tag_timeline');
    cy.contains('HALO');

    // 注目のハッシュタグタイムラインが表示されるかをチェック
    cy.visit('/@S_H_/tagged/HALO');
    cy.get('.feature_tag_timeline');
    cy.contains('HALO');
  });
});
