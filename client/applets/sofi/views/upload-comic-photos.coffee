Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

fileinput = require 'bootstrap-fileinput'
require 'bootstrap-fileinput/css/fileinput.css'


MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'
  
apiroot = '/api/dev/misc'

BootstrapFormView = require 'tbirds/views/bsformview'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ form_group_input_div } = require 'tbirds/templates/forms'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'

makePhotosObject = require '../ebutils/make-photos-object'

class PhotoEntryView extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.col-sm-2', ->
      tc.div '.listview-header', model.name
      tc.div '.listview-list-entry', ->
        tc.img '.img-responsive.img-thumbnail',
        src:"/thumbs/#{model.filename}"
        tc.button '.delete-btn.btn.btn-default',
        data:photoid:model.id, 'Delete'
  ui:
    deleteButton: '.delete-btn'
  events:
    'click @ui.deleteButton': 'deleteClicked'
  deleteClicked: ->
    photoId = @ui.deleteButton
    window.deleteButton = @ui.deleteButton
    url = "/api/dev/misc/delete-photo/#{@model.id}"
    console.log "URL", url
    console.log "MODEL", @model
    AuthModel = MainChannel.request 'main:app:AuthModel'
    model = new AuthModel
      id: @model.id
    model.urlRoot = "/api/dev/misc/delete-photo/"
    response = model.destroy()
    response.done =>
      console.log "done!", @model.collection.remove @model
      
      
class PhotoCollectionView extends Marionette.NextCollectionView
  childView: PhotoEntryView
  

class PhotosView extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.body.row'
  ui:
    body: '.body'
    deleteButton: '.delete-btn'
  regions:
    body: '@ui.body'
  onRender: ->
    collection = new Backbone.Collection @model.get 'photos'
    view = new PhotoCollectionView
      collection: collection
    @showChildView 'body', view
    
class FileInputView extends Marionette.View
  template: tc.renderable (model) ->
    tc.input '.fileinput', name:'comicphoto', type:'file'
  ui:
    fileinput: '.fileinput'
  onDomRefresh: ->
    comic_id = @model.get 'comic_id'
    fi = @ui.fileinput.fileinput
      uploadUrl: "#{apiroot}/upload-photo"
      uploadExtraData:
        comic_id: comic_id
        name: @getOption 'photoName'
      allowedFileTypes: ['image']
      allowedFileExtensions: ['jpg', 'jpeg', 'png']
      ajaxSettings:
        beforeSend: MainChannel.request 'main:app:authBeforeSend'
    fi.on 'fileunlock', =>
      response = @model.fetch()
      response.done =>
        @trigger 'photo:uploaded'
  onBeforeDestroy: ->
    @ui.fileinput.fileinput 'destroy'


class NameSelectView extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.form-group', ->
      tc.label '.control-label', for:'select_name', 'Name'
    tc.select '.form-control', name:'select_name', ->
      for item in model.items
        item_atts =
          value: item.name
        if item.name is 'front'
          item_atts.selected = ''
        tc.option item_atts, item.name
  ui:
    nameSelect: 'select[name="select_name"]'
  triggers:
    'change @ui.nameSelect': 'name:changed'
    
    
class UploadMainView extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "Upload Photos for #{model.series} ##{model.issue}"
    tc.div '.row', ->
      tc.div '.col-sm-4', ->
        tc.div '.name-select'
        tc.div '.file-div'
      tc.div '.col-sm-8', ->
        tc.div '.photo-list'
  ui:
    fileinput: '.fileinput'
    photoList: '.photo-list'
    fileInputRegion: '.file-div'
    nameSelectRegion: '.name-select'
  regions:
    photoList: '@ui.photoList'
    fileInputRegion: '@ui.fileInputRegion'
    nameSelectRegion: '@ui.nameSelectRegion'
  childViewEvents:
    'photo:uploaded': 'photoUploaded'
    'name:changed': 'nameChanged'
    
    
  photoUploaded: ->
    @showPhotoList()
    @getRegion('fileInputRegion').empty()

  showPhotoList: ->
    view = new PhotosView
      model: @model
    @showChildView 'photoList', view
    
  nameChanged: ->
    nsview = @getChildView 'nameSelectRegion'
    name = nsview.ui.nameSelect.val()
    console.log "nameChanged", name
    comic = @model.toJSON()
    photos = makePhotosObject @model.toJSON()
    if name and name not in Object.keys photos
      view = new FileInputView
        model: @model
        photoName: name
      @showChildView 'fileInputRegion', view
    else
      @getRegion('fileInputRegion').empty()
      
  onRender: ->
    collection = AppChannel.request 'db:comicphotoname:collection'
    response = collection.fetch()
    response.done =>
      view = new NameSelectView
        collection:  collection
      @showChildView 'nameSelectRegion', view
      @showPhotoList()
       
        

    
    

module.exports = UploadMainView
