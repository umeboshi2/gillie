$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ ExtraController } = require 'tbirds/controllers'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'useradmin'

defaultColumns = ['id', 'username']
CrudController = MainChannel.request 'main:app:CrudController'


class Controller extends CrudController
  channelName: 'useradmin'
  objName: 'user'
  modelName: 'user'
  initialize: (options) ->
    @applet = MainChannel.request 'main:applet:get-applet', 'adminpanel'
    @mainController = @applet.router.controller
    @channel = @getChannel()
    return
    
  ############################################
  # useradmin users
  ############################################
  list_users: ->
    require.ensure [], () =>
      ViewClass = require './userlist'
      @listItems ViewClass
    # name the chunk
    , 'useradmin-view-list-users'
    return
    
  add_new_user: ->
    require.ensure [], () =>
      { NewFormView } = require './useredit'
      @addItem NewFormView
    # name the chunk
    , 'useradmin-view-add-user'
    return

  view_user: (id) ->
    require.ensure [], () =>
      ViewClass = require './userview'
      @viewItem ViewClass, id
    # name the chunk
    , 'useradmin-view-user'
    return
    
  edit_user: (id) ->
    require.ensure [], () =>
      { EditFormView } = require './useredit'
      @editItem EditFormView, id
    # name the chunk
    , 'useradmin-edit-user'
    return

module.exports = Controller

