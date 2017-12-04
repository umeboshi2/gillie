$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'
dateFormat = require 'dateformat'
ms = require 'ms'
moment = require 'moment'

{ ProgressModel
  ProgressView } = require 'tbirds/views/simple-progress'
  
MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

ClzComicCollection = AppChannel.request "db:clzcomic:collectionClass"
class ScanCollection extends ClzComicCollection
      
class ComicScanner extends Marionette.Object
  channelName: 'sofi'
  initialize: (options) =>
    console.log "ComicScanner", options
    @modelName = options.modelName or 'clzcomic'
    @modelId = options.modelId or 'comic_id'
    @dbPrefix = "db:#{@modelName}"
    @collection = new ScanCollection
    @currentItems = _.clone options.items
    @progressModel = options.progressModel
    @progressModel.set 'valuemax', @currentItems.length
    @channel = @getChannel()
    #@on "comic:scanned", @scanI
    @on "comic:scanned", @scanItems
  events:
    'comic:scanned': 'scanItems'

  scanItem: (item) ->
    @collection.reset()
    response = @collection.fetch
      data:
        where:
          comic_id: item.id
    response.fail ->
      msg = "There was a problem talking to the server"
      MessageChannel.request 'warning', msg
    response.done =>
      comics = AppChannel.request "get-comics"
      model = comics.get item.id
      if @collection.length
        model.set 'inDatabase', true
      else
        model.set 'inDatabase', false
      @trigger 'comic:scanned'

  scanItems: ->
    position = @progressModel.get('valuemax') - @currentItems.length
    @progressModel.set 'valuenow', position
    if @currentItems.length
      item = @currentItems.pop()
      @scanItem item
    else
      @trigger "scan:completed"
      
      
class ScannerView extends Marionette.View
  regions:
    body: '.body'
    scanProgress: '.scan-progress'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "Compare CLZ XML to Database"
    tc.div '.scan-progress'
    tc.div '.body'
  initialize: (options) ->
    @comics = AppChannel.request 'get-comics'
    @currentItems = @comics.toJSON()
    
  showScannerProgressBar: ->
    @progressModel = new ProgressModel
    view = new ProgressView
      model: @progressModel
    @showChildView 'scanProgress', view
    
  scanItems: ->
    @_mgr = new ComicScanner
      modelName: 'clzcomic'
      items: @currentItems
      progressModel: @progressModel
      modelId: 'comic_id'
    @_mgr.on 'scan:completed', @scanCompleted
    @_mgr.scanItems()

  scanCompleted: =>
    console.log "SCAN COMPLETED!!!!!!!!!!!!"
    delete @_mgr
    @currentItems = []
    @comicClones = undefined
    @trigger 'scan:completed'
    
  onRender: ->
    @showScannerProgressBar()
    @scanItems()
    
module.exports = ScannerView


