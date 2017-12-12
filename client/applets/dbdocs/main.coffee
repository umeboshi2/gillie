Marionette = require 'backbone.marionette'
TkApplet = require 'tbirds/tkapplet'
AdminRouter = require '../../adminrouter'

require './dbchannel'
Controller = require './controller'

MainChannel = Backbone.Radio.channel 'global'
ResourceChannel = Backbone.Radio.channel 'resources'



class Router extends AdminRouter
  appRoutes:
    'dbdocs': 'list_pages'
    'dbdocs/documents': 'list_pages'
    'dbdocs/documents/new': 'new_page'
    'dbdocs/documents/view/:id': 'view_page'
    'dbdocs/documents/edit/:id': 'edit_page'
    
class Applet extends TkApplet
  Controller: Controller
  Router: Router

module.exports = Applet
