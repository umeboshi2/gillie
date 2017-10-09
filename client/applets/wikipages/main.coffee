Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'wikipages'

class Router extends Marionette.AppRouter
  appRoutes:
    'wikipages': 'list_wikipages'
    'wikipages/view/:name': 'view_wikipage'

    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

module.exports = Applet
