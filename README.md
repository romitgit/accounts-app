# Goal

Standardize auth logic across all Topcoder frontend apps.

This repo contains several pieces:

1. The accounts app itself, as deployed at accounts.topcoder.com
2. The connector mini-app, as deployed at accounts.topcoder.com/connector.html
3. An npm module exposing:
  - The connector-wrapper module that provides 
  - A library of shared auth functionality (token handling, etc.)

# Contributing

## Getting Started

- Make sure you have the following domains aliased to localhost: ``local.sample.topcoder-dev.com, local.accounts.topcoder-dev.com``
- ``npm install`` the updates
- Run ``npm run build:dev`` to build the accounts app to the dist folder
- Run ``npm run build:connector`` to build the connector app to the dist folder
- Navigate to ``dist`` directory and serve the index file on port 8000. I used ``python -m SimpleHTTPServer`` because this particular iframe technique does not work when served from webpack-dev-server
- ``npm run dev`` on sample-app
- Navigate to ``http://local.sample.topcoder-dev.com:3100/``

To get up and running along with https://github.com/appirio-tech/sample-app:
