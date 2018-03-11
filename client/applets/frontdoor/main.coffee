Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'

class Router extends Marionette.AppRouter
  appRoutes:
    '': 'frontdoor'
    'frontdoor': 'frontdoor'
    'frontdoor/view': 'frontdoor'
    'frontdoor/view/*name': 'viewPage'
    'frontdoor/login': 'show_login'
    'frontdoor/logout': 'show_logout'
    #FIXME
    'pages/:name': 'view_page'
    'frontdoor/upload': 'upload_view'
    'frontdoor/themes': 'themeSwitcher'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onStop: ->
    console.log "(Child) Stopping frontdoor", @.isRunning()
    super()

module.exports = Applet
