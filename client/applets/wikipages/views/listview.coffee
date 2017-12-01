Backbone = require 'backbone'
tc = require 'teacup'

Templates = require 'tbirds/templates/basecrud'
Views = require 'tbirds/crud/basecrudviews'
navigate_to_url = require 'tbirds/util/navigate-to-url'
capitalize = require 'tbirds/util/capitalize'

HasPageableCollection = require './pageable-view'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'wikipages'

base_item_template = (name, route_name) ->
  tc.renderable (model) ->
    item_btn = ".btn.btn-default.btn-xs"
    tc.li ".list-group-item.#{name}-item", ->
      tc.span '.edit-button.btn.btn-default.btn-xs', 'Edit'
      tc.text " "
      tc.span ->
        tc.a href:"##{route_name}/view/#{model.id}", model.name
        
base_list_template = (model) ->
  tc.div '.listview-header', ->
    tc.text capitalize name
  tc.button "#new-#{model.itemType}.btn.btn-default", ->
    "Add New #{capitalize model.itemType}"
  tc.hr()
  tc.ul "##{model.itemType}-container.list-group"

class ItemView extends Views.BaseItemView
  route_name: 'wikipages'
  template: base_item_template 'wikipage', 'wikipages'
  templateContext: ->
    console.log 'templateContext', @model
    return {}
    
  item_type: 'wikipages'
  ui:
    edit_item: '.edit-button'
    delete_item: '.delete-item'
    item: '.list-item'
    
  events: ->
    'click @ui.edit_item': 'edit_item'
    'click @ui.delete_item': 'delete_item'
    
  edit_item: ->
    navigate_to_url "##{@route_name}/#{@item_type}s/edit/#{@model.name}"
    
  delete_item: ->
    if __DEV__
      console.log "delete_#{@item_type}", @model
    view = new ConfirmDeleteModal
      model: @model
    if __DEV__
      console.log 'modal view', view
    show_modal view, true

  
class ListView extends Views.BaseListView
  route_name: 'wikipages'
  childView: ItemView
  childViewContainer: '#wikipage-container'
  item_type: 'wikipage'
  behaviors: [HasPageableCollection]
  templateContext:
    itemType: 'wikipage'
  template: tc.renderable (model) ->
    tc.ul '.pager', ->
      tc.li '.previous', ->
        # just .btn changes cursor to pointer
        tc.span '.prev-page-button.btn', ->
          tc.i '.fa.fa-arrow-left'
          tc.text '-previous'
      tc.li '.direction', ->
        tc.span '.direction-button.btn', ->
          tc.i '.direction-icon.fa.fa-arrow-up'
      tc.li '.next', ->
        tc.span '.next-page-button.btn', ->
          tc.text 'next-'
          tc.i '.fa.fa-arrow-right'
    base_list_template model
    
module.exports = ListView

