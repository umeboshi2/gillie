Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
jwtDecode = require 'jwt-decode'
ms = require 'ms'



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
  
keep_token_fresh = (options) ->
  options = options or {}
  token = MainChannel.request 'main:app:decode-auth-token'
  remaining = ms_remaining token
  interval = options.refreshInterval or ms '5m'
  multiple = options.refreshIntervalMultiple or 3
  access_period = 1000 * (token.exp - token.iat)
  refresh_when = access_period - (multiple * interval)
  if remaining < refresh_when
    MainChannel.request 'main:app:refresh-token', options.loginUrl
    


  
init_token = ->  
  remaining = access_time_remaining()
  token = MainChannel.request 'main:app:decode-auth-token'
  if remaining <= 0 and not token_missing token
    MessageChannel.request 'warning', 'deleting expired access token'
    MainChannel.request 'main:app:destroy-auth-token'

start_user_app = (app, appConfig) ->
  init_token()
  AuthRefresh = MainChannel.request 'main:app:AuthRefresh'
  refresh = new AuthRefresh
  response = refresh.fetch()
  response.fail ->
    if response.status == 401
      MainChannel.request 'main:app:destroy-auth-token'
      if appConfig.needLogin
        loginUrl = appConfig.authToken.loginUrl or "#frontdoor/login"
        window.location.hash = loginUrl
    app.start
      state:
        currentUser: null
  response.done ->
    token = refresh.get 'token'
    MainChannel.request 'main:app:set-auth-token', token
    # start the app
    app.start
      state:
        currentUser: MainChannel.request 'main:app:decode-auth-token'

  
module.exports =
  access_time_remaining: access_time_remaining
  keep_token_fresh: keep_token_fresh
  start_user_app: start_user_app
  



