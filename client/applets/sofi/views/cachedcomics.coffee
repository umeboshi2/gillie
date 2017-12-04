_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
imagesLoaded = require 'imagesloaded'
tc = require 'teacup'

EmptyView = require 'tbirds/views/empty'
ToolbarView = require 'tbirds/views/button-toolbar'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ form_group_input_div } = require 'tbirds/templates/forms'

HasMasonryView = require './base-masonry'
HasImageModal = require './has-image-modal'
HasHeader = require './has-header'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

toolbarEntries = [
  {
    id: 'server'
    label: 'Server Images'
    url: '#sofi'
    icon: '.fa.fa-server'
  }
  {
    id: 'browser'
    label: 'Browser Images'
    url: '#sofi'
    icon: '.fa.fa-internet-explorer'
  }
  ]

class CachedComicToolbar extends ToolbarView
  options:
    entryTemplate: tc.renderable (model) ->
      tc.i model.icon
      tc.text " "
      tc.text model.label
  onChildviewToolbarEntryClicked: (child) ->
    @trigger "toolbar:#{child.model.id}:click", child
    #console.log "onChildviewToolbarEntryClicked", child.model.id
  onDomRefresh: ->
    console.log "onDomRefresh", @regions
    eview = @getChildView 'entries'
    el = eview.$el
    el.removeClass 'btn-group-justified'
    
      
class CachedComicEntryView extends Marionette.View
  ui:
    image: 'img'
  triggers:
    'click @ui.image': 'show:image:modal'
  behaviors: [HasImageModal]
  template: tc.renderable (model) ->
    img = AppChannel.request 'fix-image-url', model.image_src
    tc.div '.item', ->
      tc.img src:img

class CachedComicCollectionView extends Marionette.CollectionView
  childView: CachedComicEntryView
  emptyView: EmptyView

destroy_entry =
  id: 'destroy'
  label: 'Delete All'
  icon: '.fa.fa-erase'

server_backup_entry =
  id: 'backup'
  label: 'Backup'
  icon: '.fa.fa-download'

server_restore_entry =
  id: 'restore'
  label: 'Restore'
  icon: '.fa.fa-upload'

browser_image_toolbar_entries = [
  destroy_entry
  ]
server_image_toolbar_entries = [
  server_backup_entry
  server_restore_entry
  ]

imgtoolbar_entries =
  browser: browser_image_toolbar_entries
  server: server_image_toolbar_entries
  
class ImageToolbar extends ToolbarView
  # skip navigating to url and bubble event up
  # to list view
  onChildviewToolbarEntryClicked: ->
  childViewTriggers:
    'toolbar:entry:clicked': 'toolbar:entry:clicked'

listContainer = '.list-container'
masonryOptions =
  gutter: 1
  isInitLayout: false
  itemSelector: '.item'
  columnWidth: 10
  horizontalOrder: false
  
class CachedComicListView extends Marionette.View
  ui: ->
    toolbar: '.toolbar'
    list: listContainer
    header: '.listview-header'
  regions:
    toolbar: '@ui.toolbar'
    list: '@ui.list'
  behaviors:
    HasMasonryView:
      behaviorClass: HasMasonryView
      listContainer: listContainer
      masonryOptions: masonryOptions
    HasHeader:
      behaviorClass: HasHeader
  template: tc.renderable (model) ->
    tc.div ->
      tc.div '.listview-header'
      tc.div '.toolbar'
      tc.div listContainer
  onRender: ->
    list = new CachedComicCollectionView
      collection: @collection
    @showChildView 'list', list
    cacheType = @getOption 'cacheType'
    toolbar = new ImageToolbar
      collection: new Backbone.Collection imgtoolbar_entries[cacheType]
      cacheType: cacheType
    @showChildView 'toolbar', toolbar
    @triggerMethod 'set:header',
    "#{@collection.length} images stored in the #{@getOption 'cacheType'}"
  onChildviewToolbarEntryClicked: (child) ->
    cacheType = @getOption 'cacheType'
    cacheTypes = ['browser', 'server']
    if cacheType in cacheTypes
      @["#{cacheType}ButtonClicked"](child)
    else
      @toolbarButtonClicked child
      
  toolbarButtonClicked: (child) ->
    console.warn "we don't have a cacheType on this toolbar"

  browserButtonClicked: (child) ->
    button = child.model.id
    if button == 'destroy'
      @destroyLocalImages()
      
  serverButtonClicked: (child) ->
    button = child.model.id
    if button == 'backup'
      @backupServerImages()
    else if button == 'restore'
      @restoreServerImages()

  backupServerImages: ->
    response = @collection.fetch()
    response.done =>
      items = []
      for item in @collection.toJSON()
        delete item.id
        items.push item
      options =
        type: 'data:text/json;charset=utf-8'
        data: JSON.stringify items: items
        el_id: 'exported-urls-anchor'
        filename: 'url-backup.json'
      MainChannel.request 'export-to-file', options
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get image urls!'
      
  restoreServerImages: ->
    @trigger 'restore:server:images'
    
  destroyLocalImages: ->
    AppChannel.request 'clear-comic-image-urls'
    @collection.reset()

insert_item = (item, options) ->
  collection = options.collection
  console.log "insert_model", collection, item
  collection.create item
  
restore_item = (item, options) ->
  collection = options.collection
  response = collection.fetch
    data:
      where:
        url: item.url
  response.fail ->
    msg = "There was a problem talking to the server"
    MessageChannel.request 'warning', msg
  response.done ->
    if not collection.length
      insert_item item, options
  
restore_comic_images = (items) ->
  comics = AppChannel.request 'db:clzpage:collection'
  options =
    collection: comics
  items.forEach (item) ->
    restore_item item, options
    
class RestoreUrlsView extends Marionette.View
  ui:
    restore_btn: '.restore-button'
    restore_lbl: '.restore-label'
    upload_btn: '.upload-button'
  events:
    'click @ui.upload_btn': 'upload_items'
    'change @ui.restore_btn': 'restore_changed'
    
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.div "Restore the image urls to the server."
    tc.label '.restore-label.btn.btn-default.btn-file', ->
      tc.span 'restore '
      tc.input '.restore-button.input', type:'file', style: 'display:none'
    tc.button '.upload-button.btn.btn-default', style: 'display:none'
    
  restore_changed: (event) ->
    #@ui.restore_btn.show()
    @ui.restore_btn.hide()
    @ui.upload_btn.show()
    @ui.restore_lbl.hide()
    @ui.restore_lbl.removeClass('btn btn-default')
    fname = event.target.files[0].name
    @ui.upload_btn.text "Upload #{fname}"
    
  reset_restore_button: ->
    @ui.restore_btn.hide()
    @ui.restore_lbl.show()
    @ui.restore_lbl.addClass('btn btn-default')
    @ui.restore_lbl.val ''
    @ui.upload_btn.hide()
    
  upload_items: ->
    file = @ui.restore_btn[0].files[0]
    reader = new FileReader()
    reader.onload = @jsonReaderOnLoad
    reader.readAsText file

  jsonReaderOnLoad: (event) =>
    content = event.target.result
    data = JSON.parse content
    if data?.items
      restore_comic_images data.items
    else
      @reset_restore_button()
    @reset_restore_button()

class ComicMainView extends Marionette.View
  ui:
    content: '.content-container'
    toolbar: '.images-toolbar'
    header: '.listview-header'
  regions:
    content: '@ui.content'
    toolbar: '@ui.toolbar'
  behaviors: [HasHeader]
  template: tc.renderable (model) ->
    tc.div ->
      tc.div '.listview-header'
      tc.div '.images-toolbar'
      tc.div '.content-container'
  onRender: ->
    toolbar = new CachedComicToolbar
      collection: new Backbone.Collection toolbarEntries
    @showChildView 'toolbar', toolbar
    @triggerMethod 'set:header', "Cached Comic Cover Images"
    
  childViewEvents:
    'toolbar:browser:click': 'view_local_storage'
    'toolbar:server:click': 'view_server_storage'
    'restore:server:images': 'restore_server_images'

  restore_server_images: ->
    view = new RestoreUrlsView
    @showChildView 'content', view
    
  view_local_storage: ->
    cachedImages = new Backbone.Collection
    locals = _.clone AppChannel.request 'get-comic-image-urls'
    delete locals.id
    Object.keys(locals).forEach (key) ->
      item =
        url: key
        image_src: locals[key]
      cachedImages.add item
    view = new CachedComicListView
      collection: cachedImages
      cacheType: 'browser'
    @showChildView 'content', view
    
  view_server_storage: ->
    comics = AppChannel.request 'db:clzpage:collection'
    response = comics.fetch()
    response.done =>
      view = new CachedComicListView
        collection: comics
        cacheType: 'server'
      @showChildView 'content', view
    response.fail ->
      MessageChannel.request 'danger', 'Failed to get cached comics'
        
module.exports = ComicMainView


