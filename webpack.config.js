require('./node_modules/coffee-script/register')
const filter = require('lodash/filter')
const HtmlWebpackPlugin = require('html-webpack-plugin')

if (process.env.CIRCLE_BRANCH === 'master') process.env.ENV = 'PROD'
if (process.env.CIRCLE_BRANCH === 'dev') process.env.ENV = 'DEV'
if (process.env.CIRCLE_BRANCH === 'qa') process.env.ENV = 'QA'


if (process.env.ENV === 'DEV') {
  process.env.ZENDESK_DOMAIN = 'topcoder.zendesk.com'
}
else if (process.env.ENV === 'QA') {
  process.env.ZENDESK_DOMAIN = 'topcoder.zendesk.com'
}
else if (process.env.ENV === 'PROD') {
  process.env.ZENDESK_DOMAIN = 'topcoder.zendesk.com'
}
else {
   // for local dev
  process.env.ZENDESK_DOMAIN = 'kohata.zendesk.com'
}

const config = require('appirio-tech-webpack-config')({
  dirname: __dirname,
  entry: {
    app: './app/index'
  },
  template: './app/index.jade',
  favicon: './app/images/favicon.ico'
})

const envOverrides = {
  auth0Domain: process.env.AUTH0_DOMAIN,
  auth0Callback:  'https://' + process.env.ACCOUNTS_DOMAIN + '/auth0-callback.html',
  AUTH0_DOMAIN: process.env.AUTH0_DOMAIN,
  ACCOUNTS_APP_URL: 'https://' + process.env.ACCOUNTS_DOMAIN + '/#!/member',
  ACCOUNTS_APP_CONNECTOR_URL: 'https://' + process.env.ACCOUNTS_DOMAIN + '/connector.html',
  AUTH0_CALLBACK:  'https://' + process.env.ACCOUNTS_DOMAIN + '/auth0-callback.html',
  AUTH0_CLIENT_ID: process.env.AUTH0_CLIENT_ID,
  USE_AUTH0_HOSTED_PAGE: true
}

Object.assign(process.env, envOverrides)

config.plugins.forEach(p =>  {
  if (p.definitions && p.definitions['process.env']) {
    p.definitions['process.env'] = JSON.stringify(Object.assign(JSON.parse(p.definitions['process.env']), envOverrides))
  }})

config.plugins.push(new HtmlWebpackPlugin({
  template: './app/auth0-hlp',
  inject: false,
  favicon: './app/images/favicon.ico',
  filename: 'auth0-hlp.html',
  DOMAIN: 'https://' + process.env.ACCOUNTS_DOMAIN + '/'
}))

config.plugins.push(new HtmlWebpackPlugin({
  template: './app/auth0-callback',
  inject: false,
  favicon: './app/images/favicon.ico',
  filename: 'auth0-callback.html',
  DOMAIN: 'https://' + process.env.ACCOUNTS_DOMAIN + '/'
}))


console.log(config.plugins)

module.exports = config
