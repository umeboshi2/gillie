Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

ToolbarView = require 'tbirds/views/button-toolbar'
{ MainController } = require 'tbirds/controllers'
{ ToolbarAppletLayout } = require 'tbirds/views/layout'
navigate_to_url = require 'tbirds/util/navigate-to-url'
scroll_top_fast = require 'tbirds/util/scroll-top-fast'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'wikipages'

toolbarEntries = [
  {
    button: '#list-button'
    label: 'List'
    url: '#wikipages'
    icon: '.fa.fa-list'
  }
  ]


toolbarEntryCollection = new Backbone.Collection toolbarEntries
AppChannel.reply 'get-toolbar-entries', ->
  toolbarEntryCollection

class Controller extends MainController
  layoutClass: ToolbarAppletLayout
  collection: AppChannel.request 'wikipage-collection'
  setup_layout_if_needed: ->
    super()
    toolbar = new ToolbarView
      collection: toolbarEntryCollection
    @layout.showChildView 'toolbar', toolbar

  _load_view: (vclass, model, objname) ->
    # FIXME
    # presume "id" is only attribute there if length is 1
    #if model.isEmpty() or Object.keys(model.attributes).length is 1
    if model.isEmpty() or not model.has 'created_at'
      response = model.fetch()
      response.done =>
        @_show_view vclass, model
        scroll_top_fast()
      response.fail ->
        msg = "Failed to load #{objname} data."
        MessageChannel.request 'danger', msg
    else
      @_show_view vclass, model
    
  list_wikipages: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      ListView = require './views/listview'
      view = new ListView
        collection: @collection
      response = @collection.fetch()
      response.done =>
        @layout.showChildView 'content', view
        if not @collection.length
          MessageChannel.request "warning", "adding initial page"
          model = new Backbone.Model
          model.url = '/api/dev/bapi/main/wikipages/X32_ABI'
          qr = model.fetch()
          qr.done =>
            window.location.hash = '#'
            
      response.fail ->
        MessageChannel.request 'danger', "Failed to load wikipages."
    # name the chunk
    , 'wikipages-list-wikipages'

  view_wikipage: (name) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      MainView = require './views/pageview'
      model = AppChannel.request 'get-wikipage', name
      console.log "MODEL", model
      @_load_view MainView, model, 'wikipage'
    # name the chunk
    , 'wikipages-view-wikipage'
      
      
module.exports = Controller

