Marionette = require 'backbone.marionette'

Controller = require './controller'

class Router extends Marionette.AppRouter
  appRoutes:
    'adminpanel/useradmin': 'listUsers'
    'adminpanel/users/list': 'listUsers'
    'adminpanel/users/add': 'addNewUser'
    'adminpanel/users/view/:id': 'viewUser'
    'adminpanel/users/edit/:id': 'editUser'

module.exports =
  router: Router
  controller: Controller
  
