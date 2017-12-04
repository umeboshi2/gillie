$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ modal_close_button } = require 'tbirds/templates/buttons'

IFrameModalView = require './iframe-modal'
ComicImageView = require './comic-image'
JsonView = require './json-modal'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

              
class BaseEntryView extends Marionette.View
  ui: ->
    info_btn: '.info-button'
    clz_link: '.clz-link'
    item: '.item'
    image: '.comic-image'
  regions: ->
    image: '@ui.image'
  events: ->
    'click @ui.info_btn': 'showJsonView'
    'click @ui.clz_link': 'showIframeView'
    
  showIframeView: (event) ->
    event.preventDefault()
    target = event.target
    if target.tagName is "A"
      view = new IFrameModalView
        model: new Backbone.Model src:target.href
      MainChannel.request 'show-modal', view
      
  showJsonView: (event) ->
    view = new JsonView
      model: @model
    MainChannel.request 'show-modal', view

  showComicImage: (clzpage) ->
    view = new ComicImageView
      model: clzpage
    @showChildView 'image', view
    
  template: tc.renderable (model) ->
    issue = model.issue
    if model?.issueext
      issue = "#{model.issue}#{model.issueext}"
    tc.div "#{model.entryClasses}.#{model.columnClass}", ->
      tc.div ".comic-image", ->
        tc.i ".fa.fa-spinner.fa-spin"
        tc.text " loading..."
      tc.div ".caption", ->
        tc.span ->
          tc.i ".info-button#{model.infoButtonClasses}"
          tc.h5 style:"text-overflow: ellipsis;",
          "#{model.series} ##{issue}"
        if model.url isnt 'UNAVAILABLE'
          tc.a '.clz-link',
          href:"#{model.url}", target:'_blank', 'cloud link'
        else
          console.log "MODEL.URL", model.url
          tc.span ".alert.alert-danger", "URL UNAVAILABLE"
          
      
module.exports = BaseEntryView



