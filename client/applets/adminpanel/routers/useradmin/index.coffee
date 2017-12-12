Marionette = require 'backbone.marionette'

Controller = require './controller'

class Router extends Marionette.AppRouter
  appRoutes:
    'adminpanel/useradmin': 'list_users'
    'adminpanel/users/list': 'list_users'
    'adminpanel/users/add': 'add_new_user'
    'adminpanel/users/view/:id': 'view_user'
    'adminpanel/users/edit/:id': 'edit_user'

module.exports =
  router: Router
  controller: Controller
  
