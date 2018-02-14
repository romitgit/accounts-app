const filter = require('lodash/filter')

const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CompressionPlugin = require('compression-webpack-plugin')

const envCopy = {} // Save this before appirio-webpack screws it up
Object.assign(envCopy, process.env)

process.env.ENV = 'DEV'
if (process.env.CIRCLE_BRANCH === 'master') process.env.ENV = 'PROD'
if (process.env.CIRCLE_BRANCH === 'dev') process.env.ENV = 'DEV'
if (process.env.CIRCLE_BRANCH === 'qa') process.env.ENV = 'QA'

require('coffee-script/register')

const baseConfig = require('appirio-tech-webpack-config')({
  dirname: __dirname
})

const envOverrides = {
  auth0Domain: envCopy.AUTH0_DOMAIN,
  AUTH0_DOMAIN: envCopy.AUTH0_DOMAIN,
  ACCOUNTS_APP_URL: 'https://' + envCopy.ACCOUNTS_DOMAIN + '/#!/member',
  ACCOUNTS_APP_CONNECTOR_URL: 'https://' + envCopy.ACCOUNTS_DOMAIN + '/connector.html',
  AUTH0_CLIENT_ID: envCopy.AUTH0_CLIENT_ID
}

Object.assign(process.env, envOverrides)

baseConfig.plugins.forEach(p =>  {
  if (p.definitions && p.definitions['process.env']) {
    p.definitions['process.env'] = JSON.stringify(Object.assign(JSON.parse(p.definitions['process.env']), envOverrides))
  }})

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
