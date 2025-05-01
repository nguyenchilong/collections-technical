/**
- Minify and Bundle JavaScript: Use tools like Webpack, Rollup, and UglifyJS to minify and bundle your JavaScript files.
- Code Splitting: Split your code into smaller chunks and load them on demand.
- Remove Unused Code: Use tools like PurgeCSS and Tree-shaking to remove unused code from your JavaScript bundle.
*/

// code example with Webpack
const path = require('path');

module.exports = {
  entry: './src/index.js',
  output: {
    filename: 'bundle.js',
    path: path.resolve(__dirname, 'dist')
  },
  mode: 'production',
  optimization: {
    splitChunks: {
      chunks: 'all'
    }
  }
};
