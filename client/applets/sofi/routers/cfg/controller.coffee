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

class CfgController extends CrudController
  channelName: 'sofi'
  objName: 'config'
  modelName: 'ebcfg'
  initialize: (options) ->
    @applet = MainChannel.request 'main:applet:get-applet', 'sofi'
    @mainController = @applet.router.controller
    @channel = @getChannel()
    console.log "@channel", @channel
    

  ############################################
  # sofi configs
  ############################################
  list_configs: ->
    require.ensure [], () =>
      ViewClass = require './cfglist'
      @listItems ViewClass
    # name the chunk
    , 'sofi-view-list-configs'
    
  add_new_config: ->
    require.ensure [], () =>
      { NewFormView } = require './cfgedit'
      @addItem NewFormView
    # name the chunk
    , 'sofi-view-add-cfg'

  view_config: (id) ->
    require.ensure [], () =>
      ViewClass = require './cfgview'
      @viewItem ViewClass, id
    # name the chunk
    , 'sofi-view-config'
    
  edit_config: (id) ->
    require.ensure [], () =>
      { EditFormView } = require './cfgedit'
      @editItem EditFormView, id
    # name the chunk
    , 'sofi-edit-config'

module.exports = CfgController

