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

const auth0DevConstants = {
  auth0Domain : 'topcoder-newauth.auth0.com',
  auth0Callback:  'https://accounts-auth0.topcoder-dev.com/auth0-callback.html',
  AUTH0_DOMAIN : 'topcoder-newauth.auth0.com',
  ACCOUNTS_APP_URL : 'https://accounts-auth0.topcoder-dev.com/#!/member',
  ACCOUNTS_APP_CONNECTOR_URL : 'https://accounts-auth0.topcoder-dev.com/connector.html',
  AUTH0_CALLBACK :  'https://accounts-auth0.topcoder-dev.com/auth0-callback.html',
  AUTH0_CLIENT_ID : 'G76ar2SI4tXz0jAyEbVGM7jFxheRnkqc',
  USE_AUTH0_HOSTED_PAGE: true
}

Object.assign(process.env, auth0DevConstants)

config.plugins.forEach(p =>  {
  if (p.definitions && p.definitions['process.env']) {
    p.definitions['process.env'] = JSON.stringify(Object.assign(JSON.parse(p.definitions['process.env']), auth0DevConstants))
  }})

config.plugins.push(new HtmlWebpackPlugin({
  template: './app/auth0-hlp',
  inject: false,
  favicon: './app/images/favicon.ico',
  filename: 'auth0-hlp.html',
  DOMAIN: process.env.ACCOUNTS_APP_URL.split('#').shift()
}))

config.plugins.push(new HtmlWebpackPlugin({
  template: './app/auth0-callback',
  inject: false,
  favicon: './app/images/favicon.ico',
  filename: 'auth0-callback.html',
  DOMAIN: process.env.ACCOUNTS_APP_URL.split('#').shift()
}))


console.log(config.plugins)

module.exports = config
