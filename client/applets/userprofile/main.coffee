Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'

require './dbchannel'
Controller = require './controller'


MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'userprofile'

class Router extends Marionette.AppRouter
  appRoutes:
    'profile': 'show_profile'
    'profile/editconfig': 'edit_config'
    'profile/chpassword': 'change_password'
    'profile/mapview': 'view_map'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

  onBeforeStart: ->
    super arguments
    AppChannel.reply 'main-controller', =>
      console.warn "Stop using 'main-controller' request on AppChannel"
      @router.controller

module.exports = Applet
