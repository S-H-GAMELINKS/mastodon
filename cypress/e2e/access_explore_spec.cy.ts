// エクスプローラーへのアクセステスト
describe('access to /explore', () => {
  beforeEach(() => {
    cy.visit('/explore');
  });

  // エクスプローラーへアクセスできているかをチェック
  it('url check', () => {
    cy.url().should('include', '/explore');
    cy.url().should('eq', 'http://localhost:3000/explore');
  });
});
