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


class PublisherSelect extends Marionette.View
  ui:
    publisher: 'select[name="select_publisher"]'
  events:
    'change @ui.publisher': 'selectionChanged'
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    tc.span '.input-group', ->
      tc.label '.control-label', for:'select_publisher',
      'Publisher'
      tc.select '.form-control', name:'select_publisher', ->
        tc.option value:'ALL', selected:'', 'All publishers'
        for item in model.items
          opts =
            value: item.publisher
          tc.option opts, item.publisher
  selectionChanged: (event) ->
    publisher = @ui.publisher.val()
    comicCollection = @getOption 'comicCollection'
    where = AppChannel.request 'locals:get', 'currentQueryWhere'
    if publisher is 'ALL'
      delete where.publisher
    else
      where.publisher = publisher
    AppChannel.request 'locals:set', 'currentQueryWhere', where
    comicCollection.state.currentPage = 0
    response = comicCollection.fetch
      data:
        where: where
    response.done ->
      comicCollection.state.currentPage = 0
      comicCollection.trigger 'pageable:state:change'
      
module.exports = PublisherSelect
