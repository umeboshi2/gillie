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
  channelName: 'global'
  viewOptions:
    fieldList: ['name']
    entryField: 'name'
    modelName: 'model'
    label: 'Model'
  setup_layout_if_needed: ->
    @mainController.setup_layout_if_needed()
  showChildView: (region, view) ->
    @mainController.layout.showChildView region, view
    
  listItems: (ViewClass) ->
    @setup_layout_if_needed()
    collection = @getChannel().request "db:#{@viewOptions.modelName}:collection"
    response = collection.fetch
      data:
        columns: @defaultColumns
    response.done =>
      options = _.extend collection:collection, @viewOptions
      view = new ViewClass options
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@viewOptions.label}s!"

  viewItem: (ViewClass, id) ->
    @setup_layout_if_needed()
    model = @getChannel().request "db:#{@viewOptions.modelName}:get", id
    response = model.fetch()
    response.done =>
      view = new ViewClass
        model: model
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@viewOptions.label}!"

  _formViewOptions: (options) ->
    options = options || {}
    options = _.extend options, @viewOptions
    options.template = MainChannel.request 'crud:template:form', options
    # FIXME fix tbirds form view to use Mn.Object
    options.channelName = @getOption 'channelName'
    return options
    
  addItem: (ViewClass) ->
    @setup_layout_if_needed()
    options = @_formViewOptions()
    view = new ViewClass options
    @showChildView 'content', view
    @scroll_top()

  editItem: (ViewClass, id, options) ->
    @setup_layout_if_needed()
    options = @_formViewOptions options
    model = @getChannel().request "db:#{@viewOptions.modelName}:get", id
    options.model = model
    response = model.fetch()
    response.done =>
      view = new ViewClass options
      @showChildView 'content', view
      @scroll_top()
    response.fail =>
      MessageChannel.request 'danger', "Failed to get #{@viewOptions.label}!"

MainChannel.reply 'main:app:CrudController', ->
  console.warn "use crud:Controller instead"
  CrudController

MainChannel.reply 'crud:Controller', ->
  CrudController
  
module.exports = CrudController


