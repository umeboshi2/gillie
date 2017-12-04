Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'
  
class PhotoNameEntry extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-list-entry', ->
      tc.text "#{model.name}  "
      tc.i '.remove-name-icon.fa.fa-minus-square'
  ui:
    removeNameIcon: '.remove-name-icon'
  events:
    'click @ui.removeNameIcon': 'removeName'
  removeName: ->
    @model.destroy()
    
class PhotoNameCollectionView extends Marionette.NextCollectionView
  childView: PhotoNameEntry
  

class MainView extends Marionette.View
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "Set Photo Names"
    tc.div '.row', ->
      tc.div '.col-sm-4.col-sm-offset-4', ->
        tc.div '.photo-names'
      tc.div '.input-group', ->
        tc.span '.input-group-btn', ->
          tc.button '.new-button.btn.btn-default', ->
            tc.text 'Add Name '
            tc.i '.fa.fa-plus-square'
        tc.input '.form-control', type:'text', name:'photoname'
  ui:
    photoNames: '.photo-names'
    newNameButton: '.new-button'
    photoNameInput: 'input[name="photoname"]'
  regions:
    photoNames: '@ui.photoNames'
  events:
    'click @ui.newNameButton': 'newNameClicked'

  newNameClicked: ->
    pname = @ui.photoNameInput.val()
    if pname
      console.log "Pname", pname
      @collection.create name:pname
      #response.done => @showPhotoNames
      @ui.photoNameInput.val ''
      
      
      
  showPhotoNames: ->
    view = new PhotoNameCollectionView
      collection: @collection
    @showChildView 'photoNames', view
      
  onRender: ->
    @collection = AppChannel.request 'db:comicphotoname:collection'
    #ComicPhotoNames = AppChannel.request 'ComicPhotoNames'
    #@collection = new ComicPhotoNames
    response = @collection.fetch()
    response.done =>
      @showPhotoNames()
    
        

    
    

module.exports = MainView
