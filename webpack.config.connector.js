const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

if (process.env.TRAVIS_BRANCH === 'master') process.env.ENV = 'PROD'
if (process.env.TRAVIS_BRANCH === 'dev') process.env.ENV = 'DEV'
if (process.env.TRAVIS_BRANCH === 'qa') process.env.ENV = 'QA'


if (process.env.ENV === 'DEV') {
  process.env.DOMAIN = 'topcoder-dev.com'
  process.env.CONNECTOR_URL = 'https://accounts.topcoder-dev.com/connector.html'
}
else if (process.env.ENV === 'QA') {
  process.env.DOMAIN = 'topcoder-qa.com'
  process.env.CONNECTOR_URL = 'https://accounts.topcoder-qa.com/connector.html'
}
else if (process.env.ENV === 'PROD') {
  process.env.DOMAIN = 'topcoder.com'
  process.env.CONNECTOR_URL = 'https://accounts.topcoder-qa.com/connector.html'
}
else {
   // for local dev
  process.env.DOMAIN = 'topcoder-dev.com'
  process.env.CONNECTOR_URL = 'http://local.accounts.topcoder-dev.com:8000/connector.html'
}

require('coffee-script/register')

const config = require('appirio-tech-webpack-config')({
  dirname: __dirname
})

module.exports = Object.assign(config, {
  entry: path.join(__dirname, '/connector/connector-embed.js'),
  output: {
    path: path.join(__dirname, 'dist/'),
    publicPath: '',
    filename: 'connector.js'
  },
  plugins: [
    new HtmlWebpackPlugin({
      inject: false,
      template: path.join(__dirname, '/connector/index.jade'),
      filename: 'connector.html'
    })
  ]
})