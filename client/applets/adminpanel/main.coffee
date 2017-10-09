Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'

class Router extends Marionette.AppRouter
  appRoutes:
    '': 'frontdoor'
    'adminpanel': 'frontdoor'
    'adminpanel/view': 'frontdoor'
    'adminpanel/login': 'show_login'
    'adminpanel/logout': 'show_logout'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onStop: ->
    console.log "(Child) Stopping adminpanel", @.isRunning()
    super()

module.exports = Applet
