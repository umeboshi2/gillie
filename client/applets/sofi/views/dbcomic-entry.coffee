_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'
require 'jquery-ui/ui/widgets/draggable'
require 'jquery-ui/ui/widgets/droppable'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ modal_close_button } = require 'tbirds/templates/buttons'

BaseComicEntryView = require './base-comic-entry'
JsonView = require './comic-entry/json-modal'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

BaseModalView = MainChannel.request 'main:app:BaseModalView'

make_simple_dl = tc.renderable (dt, dd) ->
  tc.dl '.dl-horizontal', ->
    tc.dt dt
    tc.dd dd
    
make_entry_buttons = tc.renderable (model) ->
  btn_style = '.btn.btn-default'
  tc.span ".info-button#{btn_style}", ->
    tc.i '.fa.fa-info', ' Info'
  tc.span ".photos-button#{btn_style}", ->
    text = ' Photos'
    if model?.photos?.length
      text = " #{model.photos.length} Photos"
    tc.i '.fa.fa-photo', text
  if model?.workspaceView
    if model.workspaceView is 'add'
      tc.span ".workspace-button#{btn_style}", ->
        text = ' Add'
        tc.i '.fa.fa-plus-square', style:'text-overflow:ellipsis;', text
    else
      tc.span ".workspace-button#{btn_style}", ->
        text = ' Remove'
        tc.i '.fa.fa-minus-square', style:'text-overflow:ellipsis;', text
      
dtFields = [
  'issue',
  'currentprice'
  'ReleaseDate'
  'publisher'
  'seriesgroup'
  'series'
  'quantity'
  ]

bstableclasses = [
  'table'
  'table-striped'
  'table-bordered'
  'table-hover'
  #'table-condensed'
  ]
  
make_comics_row = tc.renderable (model) ->
  tc.div '.col-sm-8', ->
    tc.table ".#{bstableclasses.join('.')}", ->
      if model?.workspace?.name
        ws = "#sofi/comics/workspace/view/#{model.workspace.name}"
        tc.tr ->
          tc.td -> tc.strong "Workspace"
          tc.td -> tc.a href:ws, model.workspace.name
      for field in dtFields
        tc.tr ->
          tc.td -> tc.strong field
          tc.td model[field]
########################################
class ComicEntryView extends BaseComicEntryView
  ui: ->
    _.extend super(),
      photos_btn: '.photos-button'
      workspace_btn: '.workspace-button'
  events: ->
    _.extend super(),
      'click @ui.photos_btn': 'managePhotos'
      'click @ui.workspace_btn': 'addToWorkspace'
  # relay show:image event to parent
  childViewTriggers:
    'show:image': 'show:image'
  templateContext: ->
    context = super()
    context.workspaceView = @getOption 'workspaceView'
    context.columnClass = 'col-sm-5'
    # do something if necessary
    atts = @model.toJSON()
    if not (context?.series? or atts?.series?)
      context.series = atts.mainsection.series.displayname
    if not context?.issue? or atts?.issue?
      context.issue = atts.issue
    if not (context?.url or atts?.url?)
      url = atts?.links?.link?.url
      if url
        context.url = url
      else
        context.url = 'UNAVAILABLE'
    return context

  template: tc.renderable (model) ->
    issue = model.issue
    if model?.issueext
      issue = "#{model.issue}#{model.issueext}"
    # .panel.panel-info
    tc.div "#{model.entryClasses}.#{model.columnClass}", ->
      tc.p '.text-center', -> tc.strong "#{model.series} ##{issue}"
      tc.div '.row', ->
        tc.div '.col-sm-2', ->
          tc.div '.comic-image.thumb'
          make_entry_buttons model
        tc.div '.col-sm-3.col-sm-offset-1', ->
          make_comics_row model
      
  # don't hide info button
  mouse_leave_item: (event) ->
    @ui.info_btn.show()
          
  managePhotos: ->
    comic_id = @model.get 'comic_id'
    navigate_to_url "#sofi/comics/photos/#{comic_id}"

  addToWorkspace: ->
    @trigger "workspace:add:comic", @model

  showJsonView: ->
    response = @model.fetch()
    response.done =>
      if @model.has 'comic'
        content = JSON.parse(@model.get('comic').content)
        view = new JsonView
          model: new Backbone.Model content
        MainChannel.request 'show-modal', view
      else
        super()

  getComicRow: ->
    if @model.has 'comic'
      return @model.get 'comic'
    else
      return @model.toJSON()
      
  onDomRefresh: ->
    @$el.draggable()
    @$el.droppable()
    comic = @getComicRow()
    url = comic.url
    if url isnt 'UNAVAILABLE'
      image_src = comic.image_src
      if image_src is 'UNSET' or image_src is undefined
        @_get_comic_data url, @_scrapeAndSetImageSrc
      else
        model = new Backbone.Model
          image_src: image_src
          url: url
        # FIXME
        # we don't need the "false" when we get the
        # comics from the db
        @showComicImage model, false
    else
      # FIXME use replacement "missing image"
      console.warn "NO IMAGE"
      @_show_unavailable_image()
      
    
  _get_comic_data: (url, cb) ->
    console.warn "_get_comic_data", url
    u = new URL url
    xhr = Backbone.ajax
      type: 'GET'
      dataType: 'html'
      url: "/clzcore#{u.pathname}"
    xhr.done ->
      cb url, xhr.responseText
    xhr.fail ->
      MessageChannel.request 'warning', "Couldn't get the info"
          
  _scrapeAndSetImageSrc: (url, content) =>
    cdoc = $.parseHTML content
    links = []
    for e in cdoc
      if e.tagName == 'LINK' and e.rel == 'image_src'
        links.push e
    if links.length > 1
      MessageChannel.request 'warning', 'Too many links for this comic.'
    link = links[0]
    @model.set 'image_src', link.href
    response = @model.save()
    response.done =>
      @showComicImage @model
    
  _show_unavailable_image: ->
    view = new Marionette.View
      template: tc.renderable ->
        tc.i '.fa.fa-exclamation-triangle.fa-4x',
        style:"width:74px;height:115px;"
    @showChildView 'image', view
    
  show_comic: ->
    image_src = @model.get 'image_src'
    console.log "show_comic image_src", image_src

    

      

module.exports = ComicEntryView


