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
    workspaceView: true
  # bubble event up to workspaceView
  childViewTriggers:
    'workspace:add:comic': 'workspace:add:comic'


UnattachedCollection = AppChannel.request 'db:unattached:collectionClass'
uc = new UnattachedCollection
window.uc = uc


class SimpleWorkspaceList extends Marionette.View
  initialize: (options) ->
    options = options or {}
  ui:
    workspace_input: "input[name='workspace']"
    newworkspace_btn: '.new-workspace-button'
    add_btn: '.add-button'
  events:
    'click @ui.newworkspace_btn': 'createNewWorkspace'
    'click @ui.add_btn': 'addClicked'

  createNewWorkspace: ->
    workspace = @ui.workspace_input.val()
    if workspace
      navigate_to_url "#sofi/comics/workspace/create/#{workspace}"

  addClicked: (event) ->
    workspace = event.target.getAttribute 'data-workspace'
    navigate_to_url "#sofi/comics/workspace/create/#{workspace}"
    
  template: tc.renderable (collection) ->
    tc.div '.listview-header', 'Workspaces'
    tc.div '.input-group', ->
      tc.span '.input-group-btn', ->
        tc.button '.new-workspace-button.btn.btn-default', ->
          tc.text 'Create workspace'
      tc.input '.form-control', type:'text', name:'workspace'
    tc.div '.workspaces', ->
      for item in collection.items
        tc.div '.panel', ->
          tc.div '.panel-body', ->
            tc.a href:"#sofi/comics/workspace/view/#{item.name}", item.name
            tc.button '.add-button.btn.btn-default.btn-xs.pull-right',
            'data-workspace':item.name, 'Add Comics'
          
  
############################################
# Main view
############################################
class MainView extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "Workspace"
    tc.div '.row', ->
      #tc.div '.sidebar.col-sm-4', style:'height: calc(100% - 50px);'
      #tc.div '.body.col-sm-8'
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
  onRender: ->
    WColl = AppChannel.request 'db:ebcomicworkspace:WorkspaceCollection'
    collection = new WColl
    view = new SimpleWorkspaceList
      collection: collection
    firstResponse = collection.fetch()
    firstResponse.done =>
      # FIXME
      # we need to do the first fetch, since
      # if the collection is empty, the next
      # fetch will produce an error on the
      # server
      if collection.length
        response = collection.fetch
          data:
            distinct: 'name'
            sort: 'name'
        response.done =>
          @showChildView 'body', view
      else
        @showChildView 'body', view
        
    
module.exports = MainView


