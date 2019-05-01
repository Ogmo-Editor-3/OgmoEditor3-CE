const CopyPlugin = require('copy-webpack-plugin');

module.exports = (env, argv) => {
  const buildMode = argv.mode || 'development';
  const debugMode = buildMode !== 'production';
  const dist = `${__dirname}/bin/`;

  return {
    entry: './app.hxml',
    target: 'electron-main',
    output: {
      filename: 'app.js',
      path: dist
    },
    module: {
      rules: [
        {
          test: /\.hxml$/,
          loader: 'haxe-loader',
          options: {
            extra: `-D build_mode=${buildMode}`,
            debug: debugMode
          }
        }
      ]
    },
    plugins: [
      new CopyPlugin([ `${__dirname}/package.json` ])
    ],
    node: {
      __dirname: false,
      __filename: false
    }
  }
}