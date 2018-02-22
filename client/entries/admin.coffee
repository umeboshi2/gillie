Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
jwtDecode = require 'jwt-decode'
ms = require 'ms'

navigate_to_url = require 'tbirds/util/navigate-to-url'
TopApp = require 'tbirds/top-app'
setupAuthModels = require 'tbirds/authmodels'
TH = require 'tbirds/token-handler'
objectEmpty = require '../object-empty'

require './base'
FooterView = require './footerview'

pkg = require '../../package.json'
pkgmodel = new Backbone.Model pkg

MainAppConfig = require './admin-config'
setupAuthModels MainAppConfig

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

show_footer = ->
  token = MainChannel.request 'main:app:decode-auth-token'
  pkgmodel.set 'token', token
  pkgmodel.set 'remaining', TH.accessTimeRemaining()
  view = new FooterView
    model: pkgmodel
  footer_region = app.getView().getRegion 'footer'
  footer_region.show view

app = new TopApp
  appConfig: MainAppConfig

if __DEV__
  # DEBUG attach app to window
  window.App = app

# register the main router
MainChannel.request 'main:app:route'

app.on 'before:start', ->
  theme = MainChannel.request 'main:app:get-theme'
  theme = if theme then theme else 'vanilla'
  MainChannel.request 'main:app:switch-theme', theme

app.on 'start', ->
  #show_footer()
  #setInterval show_footer, ms '5s'
  refreshOpts =
    refreshInterval: MainAppConfig.authToken.refreshInterval
    refreshIntervalMultiple: MainAppConfig.authToken.refreshIntervalMultiple
    loginUrl: '#frontdoor/login'
  keep_fresh = ->
    TH.keepTokenFresh refreshOpts
  setInterval keep_fresh, ms '10s'
  
  
  
TH.startUserApp app, MainAppConfig
  
module.exports = app


