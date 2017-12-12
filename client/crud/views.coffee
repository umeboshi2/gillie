Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
require 'tbirds/regions/bsmodal'
{ modal_close_button } = require 'tbirds/templates/buttons'
{ confirmDeleteTemplate } = require './templates'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'


class ConfirmDeleteModal extends Backbone.Marionette.View
  template: confirmDeleteTemplate
  ui:
    confirm_delete: '#confirm-delete-button'
    cancel_button: '#cancel-delete-button'
    
  events: ->
    'click @ui.confirm_delete': 'confirm_delete'

  confirm_delete: ->
    name = @model.get 'name'
    response = @model.destroy()
    response.done =>
      MessageChannel.request 'success', "#{name} deleted.",
    response.fail =>
      MessageChannel.request 'danger', "#{name} NOT deleted."
      
class BaseItemView extends Backbone.Marionette.View
  tagName: 'li'
  className: ->
    "list-group-item #{@item_type}-item row"
  ui:
    edit_item: '.edit-item'
    delete_item: '.delete-item'
    item: '.list-item'
    
  events: ->
    'click @ui.edit_item': 'edit_item'
    'click @ui.delete_item': 'delete_item'
    
  edit_item: ->
    navigate_to_url "##{@route_name}/#{@item_type}s/edit/#{@model.id}"
    
  _show_modal: (view, backdrop) ->
    app = MainChannel.request 'main:app:object'
    layout = app.getView()
    modal_region = layout.getRegion 'modal'
    modal_region.backdrop = backdrop
    modal_region.show view
  
  delete_item: ->
    if __DEV__
      console.log "delete_#{@item_type}", @model
    view = new ConfirmDeleteModal
      model: @model
    if __DEV__
      console.log 'modal view', view
    @_show_modal view, true
    #MainChannel.request 'main:app:show-modal', view, {backdrop:true}
    

class BaseListView extends Backbone.Marionette.CompositeView
  childViewContainer: "##{@item_type}-container"
  ui: ->
    add_item: "#add-#{@item_type}"
    
  events: ->
    'click @ui.add_item': 'add_item'

  add_item: ->
    # FIXME - fix url dont't add 's'
    navigate_to_url "##{@route_name}/#{@item_type}s/add"
    
  
MainChannel.reply 'crud:view:item', ->
  BaseItemView
MainChannel.reply 'crud:view:list', ->
  BaseListView
  
module.exports =
  BaseItemView: BaseItemView
  BaseListView: BaseListView
  

