const path    = require("path")

const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const webpack = require("webpack")
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts')

module.exports = {
  mode: "production",
  devtool: "source-map",
  module: {
    rules: [
      {
        test: /\.(js|jsx|ts|tsx|)$/,
        exclude: /node_modules/,
        use: ['babel-loader'],
      },
      {
        test: /\.(?:sa|sc|c)ss$/i,
        use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
      },
      {
        test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
        use: 'file-loader',
      },
    ],
  },
  entry: {
    admin: './app/javascript/packs/admin.jsx', 
    application: [
      "./app/javascript/packs/application.js",
      "./app/javascript/styles/application.scss"
    ],
    error: "./app/javascript/packs/error.js",
    mailer: [
      "./app/javascript/packs/mailer.js",
      "./app/javascript/styles/mailer.scss"
    ],
    public: "./app/javascript/packs/public.js",
    share: "./app/javascript/packs/share.js",
    sign_up: "./app/javascript/packs/sign_up.js",
    two_factor_authentication: "./app/javascript/packs/two_factor_authentication.js",
    creatodon: "./app/javascript/styles/application_creatodon.scss",
    kohaku: "./app/javascript/styles/application_kohaku.scss",
    mean_of_amber: "./app/javascript/styles/application_mean_of_amber.scss",
    meteor_trail: "./app/javascript/styles/application_meteor_trail.scss",
    mirroring: "./app/javascript/styles/application_mirroring.scss",
    mizuki: "./app/javascript/styles/application_mizuki.scss",
    orochi: "./app/javascript/styles/application_orochi.scss",
    twitter: "./app/javascript/styles/application_twitter.scss",
    contrast: "./app/javascript/styles/contrast.scss",
    "mastodon-light": "./app/javascript/styles/mastodon-light.scss" 
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, '..', '..', 'app/assets/builds'),
  },
  resolve: {
    extensions: ['.js', '.jsx', '.scss', '.css'],
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    }),
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin(),
  ]
}
