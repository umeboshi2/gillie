config = require './base-config'

misc_menu =
  label: 'Misc Applets'
  menu: [
    {
      label: 'Themes'
      url: '#frontdoor/themes'
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
    {
      label: 'TestUpload'
      url: '#frontdoor/upload'
      needUser: true
    }
  ]

config.navbarEntries = [
  {
    label: 'hubby'
    url: '#hubby'
    needUser: false
  }
  {
    label: 'sofi'
    url: '#sofi'
    needUser: false
  }
  {
    label: 'wikipages'
    url: '#wikipages'
    needUser: true
  }
  misc_menu
  ]


module.exports = config
