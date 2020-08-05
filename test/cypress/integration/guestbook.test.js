const randomString = () => Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

describe('guestbook', () => {
  it('saves comments', () => {
    const url = Cypress.env('URL');
    if (!url) {
      throw new Error('missing environment variable: URL')
    }

    cy.visit(url)

    const value = randomString();
    cy.get('#input')
      .type(value)
      .get('#button')
      .click()
      .waitUntil(() => cy.window().contains(value))
      .then(() => cy.reload())
      .waitUntil(() => cy.window().contains(value))
  })
})
