$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ ExtraController } = require 'tbirds/controllers'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

defaultColumns = ['id', 'name']

# @mainController should be set in initialize
class CrudController extends ExtraController
  defaultColumns: ['id', 'name']
  setup_layout_if_needed: ->
    @mainController.setup_layout_if_needed()
  showChildView: (region, view) ->
    @mainController.layout.showChildView region, view
    
  listItems: (ViewClass) ->
    @setup_layout_if_needed()
    collection = @channel.request "db:#{@modelName}:collection"
    response = collection.fetch
      data:
        columns: @defaultColumns
    response.done =>
      view = new ViewClass
        collection: collection
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@objName}s!"

  addItem: (ViewClass) ->
    @setup_layout_if_needed()
    view = new ViewClass
    @showChildView 'content', view
    @scroll_top()

  viewItem: (ViewClass, id) ->
    @setup_layout_if_needed()
    model = @channel.request "db:#{@modelName}:get", id
    response = model.fetch()
    response.done =>
      view = new ViewClass
        model: model
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@objName}!"

  editItem: (ViewClass, id) ->
    @setup_layout_if_needed()
    model = @channel.request "db:#{@modelName}:get", id
    response = model.fetch()
    response.done =>
      view = new ViewClass
        model: model
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@objName}!"

MainChannel.reply 'main:app:CrudController', ->
  CrudController
    
module.exports = CrudController


