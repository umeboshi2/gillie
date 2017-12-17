Marionette = require 'backbone.marionette'

Controller = require './controller'

class Router extends Marionette.AppRouter
  appRoutes:
    'adminpanel/useradmin': 'listUsers'
    'adminpanel/user/list': 'listUsers'
    'adminpanel/user/add': 'addNewUser'
    'adminpanel/user/view/:id': 'viewUser'
    'adminpanel/user/edit/:id': 'editUser'

module.exports =
  router: Router
  controller: Controller
  
