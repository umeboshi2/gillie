$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
ms = require 'ms'

{ MainController } = require 'tbirds/controllers'
ToolbarView = require 'tbirds/views/button-toolbar'
ShowInitialEmptyContent = require 'tbirds/behaviors/show-initial-empty'
SlideDownRegion = require 'tbirds/regions/slidedown'

SofiToolbar = require './applet-toolbar'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
ResourceChannel = Backbone.Radio.channel 'resources'
AppChannel = Backbone.Radio.channel 'sofi'



class ToolbarAppletLayout extends Backbone.Marionette.View
  behaviors:
    ShowInitialEmptyContent:
      behaviorClass: ShowInitialEmptyContent
  template: tc.renderable (model) ->
    tc.div '.col-sm-12', ->
      tc.div '.row', ->
        tc.div  '#main-toolbar.col-sm-10.col-sm-offset-1'
      tc.div '.row', ->
        tc.div '#main-content.col-sm-10.col-sm-offset-1'
  regions: ->
    region = new SlideDownRegion
      el: '#main-content'
    region.slide_speed = ms '.01s'
    content: region
    toolbar: '#main-toolbar'

button_style = "overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"

defaultColumns = ['id', 'name']

dbComicColumns = AppChannel.request 'dbComicColumns'

class SofiToolbar extends ToolbarView
  options:
    entryTemplate: tc.renderable (model) ->
      opts =
        style: button_style
      tc.span opts, ->
        tc.i model.icon
        tc.text " "
        tc.text model.label

class Controller extends MainController
  layoutClass: ToolbarAppletLayout
  setup_layout_if_needed: ->
    super()
    toolbar = new SofiToolbar
      collection: AppChannel.request 'get-toolbar-entries'
    @layout.showChildView 'toolbar', toolbar

  
  ############################################
  # sofi main views
  ############################################
  _show_main_view: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/mainview'
      view = new View
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi-view-main-view-helper'

  _show_create_csv_view: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/mkcsv'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi-view-mkcsv-view-helper'
    
  _show_preview_csv_view: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/csvpreview'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi-view-csvpreview-view-helper'
    
  _need_comics_view: (cb) ->
    comics = AppChannel.request 'get-comics'
    if comics.length
      cb()
    else
      @navigate_to_url '#sofi/xml/upload'
      
  create_csv: =>
    @setup_layout_if_needed()
    cfgs = AppChannel.request 'db:ebcfg:collection'
    dscs = AppChannel.request 'db:ebdsc:collection'
    options =
      data:
        columns: defaultColumns
    # FIXME find out why PageableCollection.fetch
    # mutates the options object
    # https://github.com/backbone-paginator/backbone.paginator/issues/347
    dscopts = _.clone options
    cfgs.fetch(options).then =>
      dscs.fetch(dscopts).then =>
        @_show_create_csv_view()
        #@_need_comics_view @_show_create_csv_view
    
  preview_csv: ->
    @setup_layout_if_needed()
    console.log "preview_csv"
    cfg = AppChannel.request 'locals:get', 'currentCsvCfg'
    dsc = AppChannel.request 'locals:get', 'currentCsvDsc'
    hlist = AppChannel.request 'get-superheroes-model'
    if cfg is undefined
      @navigate_to_url '#sofi'
      return
    else
      console.log "fetching cfg", cfg
      cfg.fetch().then (foo) =>
        console.log 'dsc is', dsc
        console.log "foo is", foo
        dsc.fetch().then =>
          hlist.fetch().then =>
            #@_need_comics_view @_show_preview_csv_view
            @_show_preview_csv_view()
    
  main_view: ->
    @setup_layout_if_needed()
    if __DEV__ and false
      comics = AppChannel.request 'get-comics'
      if not comics.length
        xml_url = '/assets/dev/comics.xml'
        xhr = Backbone.ajax
          type: 'GET'
          dataType: 'text'
          url: xml_url
        xhr.done =>
          content = xhr.responseText
          AppChannel.request 'parse-comics-xml', content, (err, json) =>
            @_show_main_view()
        xhr.fail =>
          @navigate_to_url '#sofi/xml/upload'
      else
        @_show_main_view()
    else
      @_show_main_view()
      
  dbcomics_main: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      collection = AppChannel.request "db:clzcomic:collection"
      if __DEV__
        window.dbcomics = collection
      collection.state.sortColumn = ['seriesgroup', 'series', 'issue']
      response = collection.fetch
        data:
          columns: dbComicColumns
      response.done =>
        #collection._check_state()
        View = require './views/dbcomicsview'
        view = new View
          collection: collection
        @layout.showChildView 'content', view
      response.fail ->
        MessageChannel.request 'danger', "Failed to get comics."
    # name the chunk
    , 'sofi:views:mainview'

  _showLocalComics: =>
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/comic-list'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi:views:'
    
  view_local_comics: ->
    @setup_layout_if_needed()
    @_need_comics_view @_showLocalComics
    
  upload_xml: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      comics = AppChannel.request 'get-comics'
      View = require './views/uploadxml'
      view = new View
        collection: comics
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi-view-upload-xml-view'
    
  view_cached_comics: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/cachedcomics'
      view = new View
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi-view-cached-comics-view'

  manageComicPhotos: (comic_id) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      collection = AppChannel.request "db:clzcomic:collection"
      #model = AppChannel.request "db:clzcomic:get", comic_id
      #model = AppChannel.request "db:clzcomic:new"
      if __DEV__
        window.dbcomcs = collection
      response = collection.fetch
        data:
          where:
            comic_id: comic_id
      response.done =>
        View = require './views/upload-comic-photos'
        view = new View
          model: collection.pop()
        @layout.showChildView 'content', view
    # name the chunk
    , 'sofi-manage-comic-photos-view'

    
  showWorkspaceMainView: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/workspace/list'
      view = new View
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi:views:showWorkspaceMainView'
    
  showWorkspaceView: (name) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/workspace/view'
      view = new View
        workspace: name
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi:views:showWorkspaceView'

  createWorkspaceView: (name) ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/workspace/create'
      view = new View
        workspace: name
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi:views:createWorkspaceView'

  setPhotoNames: ->
    @setup_layout_if_needed()
    require.ensure [], () =>
      View = require './views/set-photo-names'
      view = new View
      @layout.showChildView 'content', view
    # name the chunk
    , 'sofi:views:setPhotoNames'

    
module.exports = Controller
