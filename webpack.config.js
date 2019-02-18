require('./node_modules/coffee-script/register')
const filter = require('lodash/filter')
const find = require('lodash/find')

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

const es6Loader = find(config.module.loaders, loader => loader.test.toString().indexOf(".(js|jsx)" != -1))


if (es6Loader) {
  es6Loader.exclude = /node_modules\/(?!appirio|topcoder|tc|input\-moment|filestack-js)/
  // if you are seeing this console log after 6 months of its writing, feel free to remove it. it was intended to serve
  // for debugging in circle ci for some time after the hacky fix for filestack ES6 to ES5 transpilation
  console.log(es6Loader)
}

console.log(config.plugins)

module.exports = config