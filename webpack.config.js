require('./node_modules/coffee-script/register');

if (process.env.TRAVIS_BRANCH == 'master') process.env.ENV = 'PROD'
if (process.env.TRAVIS_BRANCH == 'dev') process.env.ENV = 'DEV'
if (process.env.TRAVIS_BRANCH == 'qa') process.env.ENV = 'QA'


if (process.env.ENV == 'DEV') {
  process.env.APP_LOGOUT_URL = 'https://sample.topcoder-dev.com/logout';
}
else {
  process.env.APP_LOGOUT_URL = 'http://local.sample.topcoder-dev.com:3100/logout';
}


config = require('appirio-tech-webpack-config')({
  dirname: __dirname,
  entry: {
    app: './app/index'
  },
  template: './app/index.html'
});

module.exports = config;