{ MainController } = require 'tbirds/controllers'
ToolbarView = require 'tbirds/views/button-toolbar'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
ResourceChannel = Backbone.Radio.channel 'resources'
AppChannel = Backbone.Radio.channel 'dbdocs'

{ ToolbarAppletLayout } = require 'tbirds/views/layout'

toolbarEntries = [
  {
    button: '#list-button'
    label: 'List'
    url: '#dbdocs/documents'
    icon: '.fa.fa-list'
  }
  ]


toolbarEntryCollection = new Backbone.Collection toolbarEntries
AppChannel.reply 'get-toolbar-entries', ->
  toolbarEntryCollection


class Controller extends MainController
  layoutClass: ToolbarAppletLayout
  setup_layout_if_needed: ->
    super()
    toolbar = new ToolbarView
      collection: toolbarEntryCollection
    @layout.showChildView 'toolbar', toolbar

  collection: ResourceChannel.request 'document-collection'
  
  list_pages: () ->
    @setup_layout_if_needed()
    console.log "List Pages"
    require.ensure [], () =>
      ListView = require './views/pagelist'
      view = new ListView
        collection: @collection
      response = @collection.fetch()
      response.done =>
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', "Failed to load documents."
    # name the chunk
    , 'dbdocs-view-list-pages'

  edit_page: (id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      { EditPageView } = require './views/editor'
      model = ResourceChannel.request 'get-document', id
      @_load_view EditPageView, model
    # name the chunk
    , 'dbdocs-view-edit-page'
      
  view_page: (id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      PageView = require './views/pageview'
      model = ResourceChannel.request 'get-document', id
      @_load_view PageView, model
    # name the chunk
    , 'dbdocs-view-doc-page'
      
  new_page: () ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      { NewPageView } = require './views/editor'
      view = new NewPageView
      @layout.showChildView 'content', view
    # name the chunk
    , 'dbdocs-view-new-page'
      
      
module.exports = Controller

