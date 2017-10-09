Backbone = require 'backbone'
tc = require 'teacup'

Templates = require 'tbirds/templates/basecrud'
Views = require 'tbirds/crud/basecrudviews'
navigate_to_url = require 'tbirds/util/navigate-to-url'


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
        tc.a href:"##{route_name}/view/#{model.name}", model.name
        
      tc.div '.todo-completed.checkbox.pull-right', ->
        tc.label ->
          opts =
            type: 'checkbox'
          if model.completed
            opts.checked = ''
          tc.input '.todo-checkbox', opts
          tc.text 'done'
        
class ItemView extends Views.BaseItemView
  route_name: 'wikipages'
  template: base_item_template 'wikipage', 'wikipages'
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
  template: Templates.base_list_template 'wikipage'
  childViewContainer: '#wikipage-container'
  item_type: 'wikipage'
    
module.exports = ListView

