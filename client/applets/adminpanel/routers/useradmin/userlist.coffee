Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'useradmin'

########################################
BaseItemView = MainChannel.request 'crud:view:item'
BaseListView = MainChannel.request 'crud:view:list'

templateOptions =
  name: 'user'
  entryField: 'fullname'
  routeName: 'adminpanel'
  
itemTemplate = MainChannel.request 'crud:template:item', templateOptions
listTemplate = MainChannel.request 'crud:template:list', templateOptions

class ItemView extends BaseItemView
  route_name: 'adminpanel'
  template: itemTemplate
  item_type: 'user'
  

class ListView extends BaseListView
  route_name: 'adminpanel'
  childView: ItemView
  template: listTemplate
  childViewContainer: '#user-container'
  item_type: 'user'
    
    
module.exports = ListView


