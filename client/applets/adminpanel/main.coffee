Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

class Router extends Marionette.AppRouter
  appRoutes:
    '': 'frontdoor'
    'adminpanel': 'frontdoor'
    'adminpanel/view': 'frontdoor'
    'adminpanel/login': 'show_login'
    'adminpanel/logout': 'show_logout'
  before: ->
    user = MainChannel.request 'main:app:decode-auth-token'
    if user
      if 'admins' not in user.groups
        MessageChannel.request 'danger', 'Admin access only!'
        return false
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onStop: ->
    console.log "(Child) Stopping adminpanel", @.isRunning()
    super()

module.exports = Applet
