Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'
navigate_to_url = require 'tbirds/util/navigate-to-url'

require './dbchannel'
Controller = require './controller'
AdminRouter = require '../../adminrouter'


MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

class Router extends AdminRouter
  appRoutes:
    '': 'frontdoor'
    'adminpanel': 'frontdoor'
    'adminpanel/view': 'frontdoor'
    'adminpanel/login': 'show_login'
    'adminpanel/logout': 'show_logout'
        
class Applet extends TkApplet
  Controller: Controller
  Router: Router
  extraRouters:
    useradmin: require './routers/useradmin'


  onStop: ->
    console.log "(Child) Stopping adminpanel", @.isRunning()
    super()

module.exports = Applet
