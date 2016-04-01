require('./node_modules/coffee-script/register');

if (process.env.TRAVIS_BRANCH == 'master') process.env.ENV = 'PROD'
if (process.env.TRAVIS_BRANCH == 'dev') process.env.ENV = 'DEV'
if (process.env.TRAVIS_BRANCH == 'qa') process.env.ENV = 'QA'


if (process.env.ENV == 'DEV') {
  process.env.DOMAIN = 'topcoder-dev.com';
  process.env.CONNECTOR_URL = 'https://accounts.topcoder-dev.com/connector.html';
}
else if (process.env.ENV == 'QA') {
  process.env.DOMAIN = 'topcoder-qa.com';
  process.env.CONNECTOR_URL = 'https://accounts.topcoder-qa.com/connector.html';
}
else {
   // for local dev
  process.env.DOMAIN = 'topcoder-dev.com';
  process.env.CONNECTOR_URL = 'http://local.accounts.topcoder-dev.com:8000/connector.html';
}

config = require('appirio-tech-webpack-config')({
  dirname: __dirname,
  entry: {
    app: './app/index'
  },
  template: './app/index.jade',
  favicon: './app/images/favicon.ico'
});

module.exports = config;