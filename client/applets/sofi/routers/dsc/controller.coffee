$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ ExtraController } = require 'tbirds/controllers'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

defaultColumns = ['id', 'name']
CrudController = MainChannel.request 'main:app:CrudController'


class DscController extends CrudController
  channelName: 'sofi'
  objName: 'description'
  modelName: 'ebdsc'
  initialize: (options) ->
    @applet = MainChannel.request 'main:applet:get-applet', 'sofi'
    @mainController = @applet.router.controller
    @channel = @getChannel()
    
  ############################################
  # sofi descriptions
  ############################################
  list_descriptions: ->
    require.ensure [], () =>
      ViewClass = require './dsclist'
      @listItems ViewClass
    # name the chunk
    , 'sofi-view-list-descriptions'
    
  add_new_description: ->
    require.ensure [], () =>
      { NewFormView } = require './dscedit'
      @addItem NewFormView
    # name the chunk
    , 'sofi-view-add-dsc'

  view_description: (id) ->
    require.ensure [], () =>
      ViewClass = require './dscview'
      @viewItem ViewClass, id
    # name the chunk
    , 'sofi-view-description'
    
  edit_description: (id) ->
    require.ensure [], () =>
      { EditFormView } = require './dscedit'
      @editItem EditFormView, id
    # name the chunk
    , 'sofi-edit-description'

module.exports = DscController

