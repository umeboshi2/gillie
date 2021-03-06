Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
jwtDecode = require 'jwt-decode'
ms = require 'ms'

navigate_to_url = require 'tbirds/util/navigate-to-url'
TopApp = require 'tbirds/top-app'

require './base'
FooterView = require './footerview'
TH = require './token-handler'

pkg = require '../../package.json'
pkgmodel = new Backbone.Model pkg

MainAppConfig = require './index-config'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

ms_remaining = (token) ->
  now = new Date()
  exp = new Date(token.exp * 1000)
  return exp - now

# https://stackoverflow.com/a/32108184
token_missing = (token) ->
  (Object.keys(token).length == 0 && token.constructor == Object)  
  
access_time_remaining = ->
  token = MainChannel.request 'main:app:decode-auth-token'
  if token_missing token
    return 0
  remaining = ms_remaining token
  return Math.floor(remaining / 1000)
  
show_footer = ->
  token = MainChannel.request 'main:app:decode-auth-token'
  pkgmodel.set 'token', token
  pkgmodel.set 'remaining', TH.access_time_remaining()
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
    TH.keep_token_fresh refreshOpts
  setInterval keep_fresh, ms '10s'
  
  
  
TH.start_user_app app, MainAppConfig
  
module.exports = app


