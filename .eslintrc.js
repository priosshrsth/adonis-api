module.exports = {
  extends: ['plugin:adonis/typescriptApp', 'prettier'],
  plugins: ['prettier'],
  rules: {
    'prettier/prettier': ['error'],
  },
  ignorePatterns: ['build', '.eslintrc.js'],
}
