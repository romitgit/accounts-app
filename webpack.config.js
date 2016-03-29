require('./node_modules/coffee-script/register');

if (process.env.TRAVIS_BRANCH == 'master') process.env.ENV = 'PROD'
if (process.env.TRAVIS_BRANCH == 'dev') process.env.ENV = 'DEV'
if (process.env.TRAVIS_BRANCH == 'qa') process.env.ENV = 'QA'


if (process.env.ENV == 'DEV') {
  process.env.DOMAIN = 'topcoder-dev.com';
  process.env.APP_LOGOUT_URL = 'https://sample.topcoder-dev.com/logout.html';
  process.env.MEMBER_LOGOUT_URL = 'https://www.topcoder-dev.com/logout.html';
  process.env.CONNECT_LOGOUT_URL = 'https://connect.topcoder-dev.com/logout.html';
}
else {
   // for local dev
  process.env.DOMAIN = 'topcoder-dev.com';
  process.env.APP_LOGOUT_URL = 'http://local.sample.topcoder-dev.com:3100/logout';
  process.env.MEMBER_LOGOUT_URL = 'https://www.topcoder-dev.com/logout.html';
  process.env.CONNECT_LOGOUT_URL = 'https://connect.topcoder-dev.com/logout.html';
}


config = require('appirio-tech-webpack-config')({
  dirname: __dirname,
  entry: {
    app: './app/index'
  },
  template: './app/index.jade'
});

module.exports = config;