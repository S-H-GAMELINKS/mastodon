import { defineConfig } from 'cypress';

export default defineConfig({
  e2e: {
    defaultCommandTimeout: 40000,
    experimentalSourceRewriting: true,
    supportFile: './cypress/support/e2e.ts',
  },
  retries: {
    runMode: 3,
  },
});
