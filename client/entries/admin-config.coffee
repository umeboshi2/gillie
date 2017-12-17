config = require './base-config'
config.needLogin = true
config.frontdoorApplet = 'adminpanel'

config.brand.url = '/'

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
  url: "#adminpanel/useradmin"
  needUser: true
  
SiteDocs =
  label: "Site Docs"
  url: "#dbdocs"
  needUser: true
  
config.navbarEntries = [
  SiteDocs
  UserAdmin
  misc_menu
  ]

module.exports = config
