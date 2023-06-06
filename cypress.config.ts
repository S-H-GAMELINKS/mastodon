import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    defaultCommandTimeout: 3000,
    experimentalSourceRewriting: true,
    setupNodeEvents(on, config) {
      // implement node event listeners here
    },
  },
  retries: {
    runMode: 3,
  },
});
