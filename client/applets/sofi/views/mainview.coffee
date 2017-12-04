$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'
PageableCollection = require 'backbone.paginator'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
EmptyView = require 'tbirds/views/empty'
ToolbarView = require 'tbirds/views/button-toolbar'

ComicListView = require './comic-list'
MarkdowView = require './mdview'
UploadView = require './upload-comics'
ScannerView = require './scan-comics'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'



class LocalComicsCollection extends PageableCollection
  mode: 'client'
  #state:
  #  pageSize: 10
  
class ChildToolbar extends ToolbarView
  # skip navigating to url and bubble event up
  # to list view
  onChildviewToolbarEntryClicked: ->
  childViewTriggers:
    'toolbar:entry:clicked': 'toolbar:entry:clicked'
  modelEvents:
    'change': 'somethinChanged'
  somethinChanged: ->
    console.log "somethinChanged"

toolbarEntries = [
  {
    id: 'main'
    label: 'Main View'
    icon: '.fa.fa-home'
  }
  {
    id: 'curlist'
    label: 'Current Comics'
    icon: '.fa.fa-list'
  }
  {
    id: 'scandb'
    label: 'Scan Database for Comics'
    icon: '.fa.fa-search.fa-spin'
  }
  {
    id: 'upload'
    label: 'Upload Comics'
    icon: '.fa.fa-upload'
  }
]

class ComicsView extends Marionette.View
  regions:
    toolbar: '.toolbar'
    body: '.body'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "CLZ XML to EBay File Exchange CSV"
    tc.div '.toolbar'
    tc.div '.body'

  _updateLocalComicsButton: ->
    comics = AppChannel.request 'get-comics'
    label = "#{comics.length} Local Comics"
    button = @toolbarEntries.get 'curlist'
    button.set 'label', label
    
  showToolbar: ->
    @toolbarEntries = new Backbone.Collection toolbarEntries
    toolbar = new ChildToolbar
      collection: @toolbarEntries
    @showChildView 'toolbar', toolbar
    
  showMainDoc: ->
    doc = MainChannel.request 'main:app:get-document', 'sofi-main'
    response = doc.fetch()
    response.done =>
      view = new MarkdowView
        model: doc
      @showChildView 'body', view
    response.fail ->
      MessageChannel.request 'danger', 'failed to get document'
      
  showLocalList: =>
    comics = AppChannel.request 'get-comics'
    collection = new LocalComicsCollection comics.toJSON()
    view = new ComicListView
      collection: collection
    @showChildView 'body', view
    
  showUploadView: ->
    view = new UploadView
    @showChildView 'body', view
    
  showScannerView: ->
    view = new ScannerView
    view.on "scan:completed", @showLocalList
    @showChildView 'body', view
    
  onRender: ->
    comics = AppChannel.request 'get-comics'
    if comics.length
      @showToolbar()
    @showMainDoc()
      
  onChildviewToolbarEntryClicked: (child) ->
    @_updateLocalComicsButton()
    button = child.model.id
    if button is 'curlist'
      @showLocalList()
    else if button is 'main'
      @showMainDoc()
    else if button is 'scandb'
      @showScannerView()
    else if button is 'upload'
      @showUploadView()
    else
      MessageChannel.request 'danger', 'No good, dude.'
    
module.exports = ComicsView


