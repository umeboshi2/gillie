$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
dateFormat = require 'dateformat'

DbComicEntry = require '../dbcomic-entry'
HasHeader = require '../has-header'
SeriesGroupSelect = require './seriesgroup'
PublisherSelect = require './publisher'
NavigateBox = require './navigate'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

default_entry_template = tc.renderable (model) ->
  tc.div "default_entry_template"

dbComicColumns = AppChannel.request 'dbComicColumns'
defaultComicSort = ['seriesgroup', 'series', 'issue']

sortbyInput = tc.renderable (sortColumn) ->
  tc.span '.input-group', ->
    tc.label '.control-label', for:'select_sortby', 'Sort by'
    tc.select '.form-control', name:'select_sortby', ->
      opts =
        value: 'default'
      if sortColumn is defaultComicSort
        opts.selected = ''
      tc.option opts, 'default'
      for col in dbComicColumns
        opts =
          value: col
        if sortColumn is col
          opts.selected = ''
        tc.option opts, col

class CollectionStatusSelect extends Marionette.View
  ui:
    collectionStatus: 'select[name="select_collectionstatus"]'
  events:
    'change @ui.collectionStatus': 'selectionChanged'
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    tc.span '.input-group', ->
      tc.label '.control-label', for:'select_collectionstatus',
      'Collection Status'
      tc.select '.form-control', name:'select_collectionstatus', ->
        tc.option value:'ALL', selected:'', 'All Status'
        for item in model.items
          opts =
            value: item.id
          tc.option opts, item.name
  selectionChanged: (event) ->
    collectionStatus = @ui.collectionStatus.val()
    comicCollection = @getOption 'comicCollection'
    where = AppChannel.request 'locals:get', 'currentQueryWhere'
    if collectionStatus is 'ALL'
      delete where.list_id
    else
      where.list_id = collectionStatus
    AppChannel.request 'locals:set', 'currentQueryWhere', where
    response = comicCollection.fetch
      data:
        where: where
    response.done ->
      comicCollection.state.currentPage = 0
      comicCollection.trigger 'pageable:state:change'
      
class SortBySelect extends Marionette.View
  ui:
    sort_by: 'select[name="select_sortby"]'
  events:
    'change @ui.sort_by': 'sort_collection'
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    sortColumn = model.collection.state.sortColumn
    sortbyInput sortColumn
  sort_collection: ->
    sort = @ui.sort_by.val()
    if sort is 'default'
      sort = defaultComicSort
    @collection.state.sortColumn = sort
    @collection.state.currentPage = 0
    response = @collection.fetch
      data:
        where: AppChannel.request 'locals:get', 'currentQueryWhere'
    response.done =>
      @collection.trigger 'pageable:state:change'

AuthCollection = MainChannel.request 'main:app:AuthCollection'
apiroot = "/api/dev/bapi"
SeriesGroupCollection = AppChannel.request 'db:clzcomic:SeriesGroupCollection'
PublisherCollection = AppChannel.request 'db:clzcomic:PublisherCollection'

uiRegions =
    navigatorBox: '.navigator-box'
    sortByBox: '.sort-by-box'
    collectionStatusFilterBox: '.collection-status-filter-box'
    publisherFilterBox: '.publisher-filter-box'
    seriesgroupFilterBox: '.seriesgroup-filter-box'
    
class DbComicsSidebar extends Marionette.View
  ui: uiRegions
  regions: ->
    regions = {}
    Object.keys(uiRegions).forEach (r) ->
      regions[r] = "@ui.#{r}"
    regions
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    tc.div '.navigator-box.listview-list-entry'
    tc.div '.sort-by-box.listview-list-entry'
    tc.div '.collection-status-filter-box.listview-list-entry'
    tc.div '.publisher-filter-box.listview-list-entry'
    tc.div '.seriesgroup-filter-box.listview-list-entry'
    
  showCollectionStatus: ->
    selections = AppChannel.request 'db:clzcollectionstatus:collection'
    response = selections.fetch()
    response.done =>
      view = new CollectionStatusSelect
        collection: selections
        comicCollection: @collection
      @showChildView 'collectionStatusFilterBox', view
      
  showSeriesGroupSelect: ->
    coll = new SeriesGroupCollection
    response = coll.fetch
      data:
        distinct: 'seriesgroup'
        sort: 'seriesgroup'
    response.done =>
      view = new SeriesGroupSelect
        collection: coll
        comicCollection: @collection
      @showChildView 'seriesgroupFilterBox', view
      window.sgview = view
      
  showPublisherSelect: ->
    coll = new PublisherCollection
    response = coll.fetch
      data:
        distinct: 'publisher'
        sort: 'publisher'
    response.done =>
      view = new PublisherSelect
        collection: coll
        comicCollection: @collection
      @showChildView 'publisherFilterBox', view
      
  showSortBySelect: ->
    sortbyview = new SortBySelect
      collection: @collection
    @showChildView 'sortByBox', sortbyview
    
  showNavigatorBox: ->
    view = new NavigateBox
      collection: @collection
    @showChildView 'navigatorBox', view
    
  onRender: ->
    # show child views
    @showNavigatorBox()
    @showCollectionStatus()
    @showPublisherSelect()
    @showSeriesGroupSelect()
    @showSortBySelect()
    if @getOption 'workspaceSidebar'
      console.warn "workspaceSidebar!!!!!!!!"

module.exports = DbComicsSidebar


