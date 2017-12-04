$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

{ ProgressModel
  ProgressView } = require 'tbirds/views/simple-progress'
parseReleaseDate = require '../ebutils/parse-releasedate'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

class UploadManager extends Marionette.Object
  channelName: 'sofi'
  initialize: (options) =>
    @modelName = options.modelName or 'clzcomic'
    @modelId = options.modelId or 'comic_id'
    @dbPrefix = "db:#{@modelName}"
    @collection = AppChannel.request "#{@dbPrefix}:collection"
    @currentItems = _.clone options.items
    @progressModel = options.progressModel
    @progressModel.set 'valuemax', @currentItems.length
    @channel = @getChannel()
    @channel.on "#{@dbPrefix}:inserted", @restore_items_now
    @channel.on "#{@dbPrefix}:updated", @restore_items_now
    console.log 'channel is', @channel
  insert_item: (item) ->
    if @collection.length
      throw new Error "We cannot insert!!!!"
    response = @channel.request "#{@dbPrefix}:add", item
    #response.fail ->
    #  title = "#{item.series} #{item.issue} id:#{item.comic_id}"
    #  MessageChannel.request 'danger', "Unable to insert #{title}"
  update_item: (item) ->
    if @collection.length != 1
      throw new Error "Not unique error!!!"
    model = @collection.models[0]
    response = @channel.request "#{@dbPrefix}:updatePassed", model, item
    response.fail ->
      title = "#{item.series} #{item.issue} id:#{item.comic_id}"
      MessageChannel.request 'danger', "Unable to update #{title}"
    
  restore_item: (item) ->
    # reset collection to help check for multiples
    @collection.reset()
    response = @collection.fetch
      data:
        where:
          "#{@modelId}": item[@modelId]
    response.fail ->
      msg = "There was a problem talking to the server"
      MessageChannel.request 'warning', msg
    response.done =>
      if @collection.length > 1
        MessageChannel.request 'warning', "#{name} is not unique!"
      if not @collection.length
        @insert_item item
      else
        @update_item item
      
  restore_items: =>
    position = @progressModel.get('valuemax') - @currentItems.length
    @progressModel.set 'valuenow', position
    if @currentItems.length
      item = @currentItems.pop()
      @restore_item item
    else
      MessageChannel.request 'success', "Restoration Successful"
      console.log "Stop Listening!!!!!!!!!!!!!!!!!!!!!!!"
      @channel.off "#{@dbPrefix}:inserted"
      @channel.off "#{@dbPrefix}:updated"
      @trigger "upload:completed"
      
  restore_items_now: =>
    #console.log "RESTORE_ITEMS_NOW!!!!!"
    @restore_items()
    

class UploadView extends Marionette.View
  regions:
    body: '.body'
    createProgress: '.create-progress'
    uploadProgress: '.upload-progress'
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "CLZ XML to EBay File Exchange CSV"
    tc.div '.create-progress'
    tc.div '.upload-progress'
    tc.div '.body'
  events:
    'item:created': 'create_items'
  initialize: (options) ->
    @comics = AppChannel.request 'get-comics'
    
    
  showUploadProgressBar: ->
    @uploadModel = new ProgressModel
    view = new ProgressView
      model: @uploadModel
    @showChildView 'uploadProgress', view

  showCreateProgressBar: ->
    @createModel = new ProgressModel
    view = new ProgressView
      model: @createModel
    @showChildView 'createProgress', view

  _createAttributes: (comic) ->
    #console.log "COMIC", comic
    attributes =
      comic_id: comic.id
      index: comic.index
      list_id: comic.collectionstatus.$.listid
      bpcomicid: comic.bpcomicid
      bpseriesid: comic.bpseriesid
      # FIXME
      rare: false
      publisher: comic?.publisher?.displayname
      releasedate: parseReleaseDate comic.releasedate.date
      seriesgroup: comic?.seriesgroup?.displayname or 'UNGROUPED'
      series: comic.mainsection.series.displayname
      quantity: comic.quantity
      currentprice: comic.currentpricefloat
      content: comic
    url = comic?.links?.link?.url
    if url
      attributes.url = url
    issue = comic.issue
    if comic.issueext
      attributes.issueext = comic.issueext
      issue = comic.issue
      if not issue.endsWith comic.issueext
        console.warn "THIS IS BAD", issue, comic.issueext
      else
        #console.log "THIS IS GOOD", issue, comic.issueext
        issue = issue.split(comic.issueext)[0]
    if not issue
      issue = 0
    attributes.issue = issue
    return attributes
    
  createComicDbItem: (comic) ->
    attributes = @_createAttributes comic
    @currentItems.push attributes
    @createModel.set 'valuenow', @currentItems.length
    if @currentItems.length != @comics.length
      setTimeout =>
        @createAnotherItem()
      , 5
      #@createAnotherItem()
    else
      console.log "FINISHED CREATING"
      @uploadItems()
      
  createAnotherItem: ->
    if @comicClones.length
      comic = @comicClones.pop()
      @createComicDbItem comic
      
  createItems: ->
    comics = @comics
    clones = _.clone @comics
    @comicClones = clones.toJSON()
    @createModel.set 'valuemax', @comicClones.length
    @createModel.set 'valuenow', 0
    @currentItems = []
    comic = @comicClones.pop()
    @createComicDbItem comic

  uploadItems: ->
    @_mgr = new UploadManager
      modelName: 'clzcomic'
      items: @currentItems
      progressModel: @uploadModel
      modelId: 'comic_id'
    @_mgr.on 'upload:completed', @uploadCompleted
    @_mgr.restore_items()
    
  uploadCompleted: =>
    console.log "UPLOAD COMPLETED!!!!!!!!!!!!"
    delete @_mgr
    @currentItems = []
    @comicClones = undefined
    
  onRender: ->
    @showCreateProgressBar()
    @showUploadProgressBar()

  onDomRefresh: ->
    console.log "onDomRefresh UploadView"
    setTimeout =>
      @createItems()
    , 10
module.exports = UploadView


