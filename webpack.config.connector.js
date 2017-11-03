const filter = require('lodash/filter')

const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CompressionPlugin = require('compression-webpack-plugin')

if (process.env.CIRCLE_BRANCH === 'master') process.env.ENV = 'PROD'
if (process.env.CIRCLE_BRANCH === 'dev') process.env.ENV = 'DEV'
if (process.env.CIRCLE_BRANCH === 'qa') process.env.ENV = 'QA'

require('coffee-script/register')

const baseConfig = require('appirio-tech-webpack-config')({
  dirname: __dirname
})

const auth0DevConstants = {
  auth0Domain : 'topcoder-newauth.auth0.com',
  AUTH0_DOMAIN : 'topcoder-newauth.auth0.com',
  ACCOUNTS_APP_URL : 'https://accounts-auth0.topcoder-dev.com/#!/member',
  ACCOUNTS_APP_CONNECTOR_URL : 'https://accounts-auth0.topcoder-dev.com/connector.html',
  AUTH0_CLIENT_ID : 'G76ar2SI4tXz0jAyEbVGM7jFxheRnkqc'
}

Object.assign(process.env, auth0DevConstants)

baseConfig.plugins.forEach(p =>  {
  if (p.definitions && p.definitions['process.env']) {
    p.definitions['process.env'] = JSON.stringify(Object.assign(JSON.parse(p.definitions['process.env']), auth0DevConstants))
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
