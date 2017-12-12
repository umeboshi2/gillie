$ = require 'jquery'
_ = require 'underscore'
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
  viewOptions:
    entryField: 'name'
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
      options = _.extend collection:collection, @viewOptions
      view = new ViewClass options
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@objName}s!"

  addItem: (ViewClass) ->
    @setup_layout_if_needed()
    options = _.extend {}, @viewOptions
    options.template = MainChannel.request 'crud:template:form', options
    view = new ViewClass @viewOptions
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

  editItem: (ViewClass, id, options) ->
    options = options || {}
    options = _.extend options, @viewOptions
    options.template = MainChannel.request 'crud:template:form', options
    @setup_layout_if_needed()
    model = @channel.request "db:#{@modelName}:get", id
    options.model = model
    response = model.fetch()
    response.done =>
      view = new ViewClass options
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@objName}!"

MainChannel.reply 'main:app:CrudController', ->
  console.warn "use crud:controller instead"
  CrudController

MainChannel.reply 'crud:controller', ->
  CrudController
  
module.exports = CrudController


