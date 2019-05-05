const { spawn } = require('child_process');

module.exports = (env, argv) => {
  const buildMode = argv.mode || 'development';
  const debugMode = buildMode !== 'production';
  const dist = `${__dirname}/bin/`;

  return {
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
          use: 'file-loader'
        },
        {
          test: /\.(woff|woff2|eot|ttf|otf)$/,
          use: 'file-loader'
        },
        {
          test:/\.(s*)css$/,
          use:['style-loader','css-loader', 'sass-loader']
        },
        {
          test: /\.node$/,
          use: 'node-loader'
        }
      ]
    },
    devtool: 'source-map',
    devServer: {
      contentBase: dist,
      overlay: true,
      hot: true,
      stats: {
        colors: true,
        chunks: false,
        children: false
      },
      before() {
        spawn(
          'electron',
          [dist],
          { shell: true, env: process.env, stdio: 'inherit' }
        )
        .on('close', code => process.exit(0))
        .on('error', spawnError => console.error(spawnError))
      }
    }
  }
}