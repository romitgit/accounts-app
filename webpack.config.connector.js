const filter = require('lodash/filter')

const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CompressionPlugin = require('compression-webpack-plugin')

if (process.env.TRAVIS_BRANCH === 'master') process.env.ENV = 'PROD'
if (process.env.TRAVIS_BRANCH === 'dev') process.env.ENV = 'DEV'
if (process.env.TRAVIS_BRANCH === 'qa') process.env.ENV = 'QA'

require('coffee-script/register')

const baseConfig = require('appirio-tech-webpack-config')({
  dirname: __dirname
})

const plugins = baseConfig.plugins.filter( (plugin) => !(plugin instanceof HtmlWebpackPlugin) && !(plugin instanceof CompressionPlugin) )

plugins.push(new HtmlWebpackPlugin({
  inject: false,
  template: path.join(__dirname, '/connector/index.jade'),
  filename: 'connector.html'
}))

const config = Object.assign(baseConfig, {
  entry: path.join(__dirname, '/connector/connector-embed.js'),
  output: {
    path: path.join(__dirname, 'dist/'),
    publicPath: '',
    filename: 'connector.js'
  },
  plugins
})

console.log(config.plugins)

module.exports = config
