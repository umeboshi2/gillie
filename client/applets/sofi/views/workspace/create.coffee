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
    workspaceView: 'add'
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
      tc.text "Create workspace #{model.workspace}"
    tc.div '.row', ->
      tc.div '.sidebar.col-sm-4', style:'height: calc(100% - 50px);'
      tc.div '.body.col-sm-8'
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
    @showChildView 'body', view
    
  onRender: ->
    @renderView()
    
  renderView: ->
    UnattachedCollection = AppChannel.request 'db:unattached:collectionClass'
    collection = new UnattachedCollection
    response = collection.fetch()
    response.done =>
      @showSidebar collection
      @showBody collection
    @collection = collection
    
      
  onWorkspaceAddComic: (model) ->
    workspace = @getOption 'workspace'
    console.log "MODEL", model
    comic_id = model.get 'comic_id'
    console.log "handle onWorkspaceAddComic", workspace, comic_id
    collection = AppChannel.request 'db:ebcomicworkspace:collection'
    collection.on 'add', =>
      @collection.fetch()
      collection.off 'add'
    data =
      comic_id: comic_id
      name: workspace
    model = collection.create data, wait:true
    
    
    
module.exports = MainView


