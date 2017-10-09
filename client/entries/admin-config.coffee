config = require 'tbirds/app-config'
config.userMenuApp = require './user-menu-view'
config.hasUser = true
config.needLogin = true
config.appletRoutes.profile = 'userprofile'
config.frontdoorApplet = 'adminpanel'

config.brand.label = 'Gillie'
config.brand.url = '/'

config.authToken = {}
config.authToken.refreshInterval = '5m'
# for testing authToken
if __DEV__ and false
  config.authToken.refreshInterval = '10s'
config.authToken.refreshIntervalMultiple = 3

misc_menu =
  label: 'Misc Applets'
  menu: [
    {
      label: 'Themes'
      url: '#adminpanel/themes'
    }
    {
      label: 'Bumblr'
      url: '#bumblr'
    }
    {
      label: 'Todos'
      url: '#todos'
      needUser: true
    }
  ]

UserAdmin =
  label: "User Admin"
  url: "#useradmin"
  needUser: true
  
config.navbarEntries = [
  UserAdmin
  misc_menu
  ]

module.exports = config
