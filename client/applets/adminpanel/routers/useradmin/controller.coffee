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
  viewOptions:
    fieldList: ['username', 'fullname', 'email']
    entryField: 'fullname'
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
  listUsers: ->
    require.ensure [], () =>
      ViewClass = require './userlist'
      @listItems ViewClass
    # name the chunk
    , 'useradmin-view-list-users'
    return

  addItem: (ViewClass) ->
    @setup_layout_if_needed()
    view = new ViewClass 
    @showChildView 'content', view
    @scroll_top()

  addNewUser: ->
    NewFormView = MainChannel.request 'crud:view:new-item'
    @addItem NewFormView @viewOptions
    return

  viewUser: (id) ->
    require.ensure [], () =>
      ViewClass = require './userview'
      @viewItem ViewClass, id
    # name the chunk
    , 'useradmin-view-user'
    return
    
  editUser: (id) ->
    EditFormView = MainChannel.request 'crud:view:edit-item'
    @editItem EditFormView, id
    return

module.exports = Controller

