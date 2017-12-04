_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'
dateFormat = require 'dateformat'
#require('editable-table/mindmup-editabletable')

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'


class SeriesGroupSelect extends Marionette.View
  initialize: (options) ->
    comicCollection = @getOption 'comicCollection'
    comicCollection.on 'pageable:state:change', @onComicCollectionChanged
  ui:
    seriesgroup: 'select[name="select_seriesgroup"]'
  events:
    'change @ui.seriesgroup': 'selectionChanged'
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    tc.span '.input-group', ->
      tc.label '.control-label', for:'select_seriesgroup',
      'Series Group'
      tc.select '.form-control', name:'select_seriesgroup', ->
        tc.option value:'ALL', selected:'', 'Every Series Group'
        for item in model.items
          opts =
            value: item.seriesgroup
          tc.option opts, item.seriesgroup
  selectionChanged: (event) ->
    seriesgroup = @ui.seriesgroup.val()
    comicCollection = @getOption 'comicCollection'
    where = AppChannel.request 'locals:get', 'currentQueryWhere'
    if seriesgroup is 'ALL'
      delete where.seriesgroup
    else
      where.seriesgroup = seriesgroup
    AppChannel.request 'locals:set', 'currentQueryWhere', where
    comicCollection.state.currentPage = 0
    response = comicCollection.fetch
      data:
        where: where
    response.done ->
      comicCollection.state.currentPage = 0
      comicCollection.trigger 'pageable:state:change'
  onComicCollectionChanged: (event) =>
    seriesgroup = @ui.seriesgroup.val()
    where = AppChannel.request 'locals:get', 'currentQueryWhere'
    where = _.clone where
    if where?.seriesgroup
      delete where.seriesgroup
    response = @collection.fetch
      data:
        distinct: 'seriesgroup'
        sort: 'seriesgroup'
        where: where
    response.done =>
      @render()
      @ui.seriesgroup.val seriesgroup
      if @ui.seriesgroup.val() is null
        @ui.seriesgroup.val 'ALL'
        
    
module.exports = SeriesGroupSelect
