scripts    = document.getElementsByTagName 'script'
src        = scripts[scripts.length - 1].getAttribute 'src'
publicPath = src.substr 0, src.lastIndexOf('/' + 1)

__webpack_public_path__ = publicPath

require 'angular'
require 'angular-ui-router'
require 'angular-messages'
require 'auth0-angular'
require 'auth0-js'

require './app.module'
require './app-config'
require './app-run'

require 'appirio-tech-ng-auth'

requireContextFiles = (files) ->
  paths = files.keys()

  for path in paths
    files path

requireContextFiles require.context './styles/', true, /^(.*\.(scss$))[^.]*$/igm
requireContextFiles require.context './scripts/', true, /^(.*\.(coffee$))[^.]*$/igm
