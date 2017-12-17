config = require 'tbirds/app-config'
config.userMenuApp = require './user-menu-view'
config.hasUser = true
config.appletRoutes.profile = 'userprofile'

config.brand.label = 'Gillie'
config.brand.url = '#'

config.authToken = {}
config.authToken.refreshInterval = '5m'
# for testing authToken
if __DEV__ and false
  config.authToken.refreshInterval = '10s'
config.authToken.refreshIntervalMultiple = 3
config.authToken.loginUrl = '#frontdoor/login'

config.appRegion = '#root-div'
module.exports = config
