// プロフィール編集画面でのヘッダー画像アップロードE2Eテスト
describe('media upload test', () => {
  beforeEach(() => {
    cy.visit('/auth/sign_in');
    cy.get('#user_email').type(Cypress.env('email'));
    cy.get('#user_password').type(`${Cypress.env('password')}{enter}`);
    cy.location('pathname', { timeout: 10000 }).should(
      'not.eq',
      '/auth/sign_in',
    );

    cy.intercept('GET', '**/api/v1/profile').as('getProfile');
    cy.visit('/profile/edit');
    cy.wait('@getProfile');
    cy.get(
      'header button[title="Add image"], header button[title="Replace image"]',
      { timeout: 10000 },
    ).should('have.length.at.least', 1);
  });

  it('can upload a cover photo from the current profile edit UI', () => {
    cy.intercept('PATCH', '**/api/v1/profile').as('updateProfile');

    cy.get(
      'header button[title="Add image"], header button[title="Replace image"]',
    )
      .first()
      .click({ force: true });

    cy.get('body', { timeout: 10000 })
      .should(($body) => {
        expect(
          $body.find(
            '.dialog-modal, .dropdown-menu__item button[data-index="0"]',
          ).length,
        ).to.be.greaterThan(0);
      })
      .then(($body) => {
        const coverPhotoButton = $body.find(
          '.dropdown-menu__item button[data-index="0"]',
        );

        if (coverPhotoButton.length > 0) {
          cy.wrap(coverPhotoButton.first()).click({ force: true });
        }
      });

    cy.get('.dialog-modal', { timeout: 10000 }).should('be.visible');
    cy.contains(
      '.dialog-modal__header__title',
      /cover photo|profile photo/,
    ).should('be.visible');
    cy.contains('.dialog-modal button', 'Browse files').should('be.visible');

    cy.get('.dialog-modal input[type="file"]').selectFile(
      'cypress/fixtures/header.png',
      { force: true },
    );

    cy.contains('.dialog-modal button', 'Next', { timeout: 10000 }).click();
    cy.contains('.dialog-modal button', 'Done', { timeout: 10000 }).click();

    cy.wait('@updateProfile').its('response.statusCode').should('eq', 200);
    cy.get('.dialog-modal').should('not.exist');
    cy.get('header img').first().should('have.attr', 'src').and('not.be.empty');
  });
});
