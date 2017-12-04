$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'
dateFormat = require 'dateformat'
#require('editable-table/mindmup-editabletable')
require 'jquery-ui/ui/widgets/droppable'

navigate_to_url = require 'tbirds/util/navigate-to-url'

DbComicEntry = require '../dbcomic-entry'
DbComicsSidebar = require '../ws-sidebar'
HasHeader = require '../has-header'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

default_entry_template = tc.renderable (model) ->
  tc.div "default_entry_template"

dbComicColumns = AppChannel.request 'dbComicColumns'

directionLabel =
  asc: 'ascending'
  desc: 'descending'

class DbComicEntryCollectionView extends Marionette.NextCollectionView
  childView: DbComicEntry
  childViewOptions:
    workspaceView: 'remove'
  # bubble event up to workspaceView
  childViewTriggers:
    'workspace:add:comic': 'workspace:add:comic'


UnattachedCollection = AppChannel.request 'db:unattached:collectionClass'

class WorkspaceView extends Marionette.View
  behaviors: [HasHeader]
  ui:
    header: '.listview-header'
    entries: '.dbcomics-entries'
  regions:
    entries: '@ui.entries'
  template: tc.renderable (model) ->
    tc.div '.listview-header'
    tc.div '.dbcomics-entries.row'
  # bubble event up to main view
  childViewTriggers:
    'workspace:add:comic': 'workspace:add:comic'
    
  updateHeader: ->
    state = @collection.state
    totalRecords = state.totalRecords
    unless totalRecords is null
      currentPage = state.currentPage
      totalPages = state.totalPages
      direction = directionLabel[state.sortDirection]
      msg = "Page #{currentPage + 1} of #{totalPages}, #{direction}"
      msg = msg + " pages, with #{totalRecords} comics total."
      @triggerMethod 'set:header', msg
    else
      msg = "No comics in workspace"
      @triggerMethod 'set:header', msg
      
  onRender: ->
    entryTemplate = @options.entryTemplate or default_entry_template
    @collectionView = new DbComicEntryCollectionView
      collection: @collection
      entryTemplate: entryTemplate
      workspace: @getOption 'workspace'
      childViewOptions:
        workspaceView: 'remove'
        workspace: @getOption 'workspace'
    @showChildView 'entries', @collectionView
    @updateHeader()
    @collection.on 'pageable:state:change', =>
      @updateHeader()
    
  onBeforeDestroy: ->
    @collection.off 'pageable:state:change'

############################################
# Main view
############################################
class MainView extends Marionette.View
  templateContext: ->
    workspace: @getOption 'workspace'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "View workspace #{model.workspace}"
    tc.div '.row', ->
      tc.div '.body.col-sm-12'
      tc.div '.body'
  ui:
    body: '.body'
    sidebar: '.sidebar'
  regions:
    body: '@ui.body'
    sidebar: '@ui.sidebar'
  childViewEvents:
    'workspace:add:comic': 'onWorkspaceAddComic'
    'workspace:changed': 'onWorkspaceChanged'

  showSidebar: (collection) ->
    sidebar = new DbComicsSidebar
      collection: collection
      workspaceSidebar: true
    @showChildView 'sidebar', sidebar

  showBody: (collection) ->
    view = new WorkspaceView
      collection: collection
      workspace: @getOption 'workspace'
    @showChildView 'body', view
    
  onRender: ->
    @renderView()
    
  renderView: ->
    WsCollection = AppChannel.request 'db:ebcomicworkspace:collectionClass'
    workspace = @getOption 'workspace'
    collection = new WsCollection
    # FIXME
    collection.setPageSize 100000
    fetchdata =
      where:
        name: workspace
    response = collection.fetch
      data: fetchdata
    response.done =>
      console.log "collection.length", collection.length
      @showBody collection
    
  # FIXME this needs to be renamed somewhere
  # This deletes the comic
  onWorkspaceAddComic: (model) ->
    response = model.destroy()
    
module.exports = MainView


