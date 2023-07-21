module.exports = {
  env: {
    browser: true,
    es2021: true,
    jest: {
      globals: true,
    },
  },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 12,
    sourceType: 'module',
  },
  plugins: [
    'react',
    '@typescript-eslint'
  ],
  rules: {},
  settings: {
    'import/resolver': 'webpack',
    react: { version: '17' }
  },
};
