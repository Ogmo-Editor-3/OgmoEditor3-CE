const CopyPlugin = require('copy-webpack-plugin');
const buildMode = process.env.NODE_ENV || 'development';
const debugMode = buildMode !== 'production';
const dist = `${__dirname}/bin/`;

ogmoConfig = {
  mode: 'development',
  devtool: 'source-map',
  entry: './ogmo.hxml',
  target: 'electron-renderer',
  output: {
    filename: 'ogmo.js',
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
      },
      {
        test: /\.(png|jpg|gif)$/,
        use: ['file-loader']
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf)$/,
        use: ['file-loader']
      },
      {
        test:/\.(s*)css$/,
        use:['style-loader','css-loader', 'sass-loader']
      }
    ]
  },
  plugins: [
    new CopyPlugin([
      { from: 'assets' },
      'package.json'
    ])
  ]
}

electronConfig = {
  mode: 'development',
  devtool: 'source-map',
  entry: './app.hxml',
  target: 'electron-main',
  node: {
    __dirname: false,
    __filename: false
  },
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
  }
}

module.exports = [ogmoConfig, electronConfig]