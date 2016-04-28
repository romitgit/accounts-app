const filter = require('lodash/filter')

const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

if (process.env.TRAVIS_BRANCH === 'master') process.env.ENV = 'PROD'
if (process.env.TRAVIS_BRANCH === 'dev') process.env.ENV = 'DEV'
if (process.env.TRAVIS_BRANCH === 'qa') process.env.ENV = 'QA'

require('coffee-script/register')

const config = require('appirio-tech-webpack-config')({
  dirname: __dirname
})

const plugins = config.plugins.filter( (plugin) => !plugin instanceof HtmlWebpackPlugin )

plugins.push(new HtmlWebpackPlugin({
  inject: false,
  template: path.join(__dirname, '/connector/index.jade'),
  filename: 'connector.html'
}))

module.exports = Object.assign(config, {
  entry: path.join(__dirname, '/connector/connector-embed.js'),
  output: {
    path: path.join(__dirname, 'dist/'),
    publicPath: '',
    filename: 'connector.js'
  },
  plugins
})