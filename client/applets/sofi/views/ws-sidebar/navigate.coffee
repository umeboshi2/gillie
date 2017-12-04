$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
dateFormat = require 'dateformat'

DbComicEntry = require '../dbcomic-entry'
HasHeader = require '../has-header'
SeriesGroupSelect = require './seriesgroup'
PublisherSelect = require './publisher'
WorkspaceView = require './workspace'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

default_entry_template = tc.renderable (model) ->
  tc.div "default_entry_template"

dbComicColumns = AppChannel.request 'dbComicColumns'
defaultComicSort = ['seriesgroup', 'series', 'issue']

class NavigateBox extends Marionette.View
  tagName: 'ul'
  className: 'pager'
  ui:
    prev_li: '.previous'
    next_li: '.next'
    prev_button: '.prev-page-button'
    dir_button: '.direction-button'
    dir_icon: '.direction-icon'
    next_button: '.next-page-button'
  events:
    'click @ui.prev_button': 'get_prev_page'
    'click @ui.dir_button': 'toggle_sort_direction'
    'click @ui.next_button': 'get_next_page'
  # relay show:image event to parent
  childViewTriggers:
    "workspace:changed" : "workspace:changed"
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    tc.li '.previous', ->
      # just .btn changes cursor to pointer
      tc.span '.prev-page-button.btn', ->
        tc.i '.fa.fa-arrow-left'
        tc.text '-previous'
    tc.li '.direction', ->
      tc.span '.direction-button.btn', ->
        tc.i '.direction-icon.fa.fa-arrow-up'
    tc.li '.next', ->
      tc.span '.next-page-button.btn', ->
        tc.text 'next-'
        tc.i '.fa.fa-arrow-right'
  update_nav_buttons: ->
    currentPage = @collection.state.currentPage
    if currentPage
      @ui.prev_li.show()
    else
      @ui.prev_li.hide()
    if currentPage != @collection.state.lastPage
      @ui.next_li.show()
    else
      @ui.next_li.hide()
    if @collection.state.totalRecords is 0
      @ui.prev_li.hide()
      @ui.next_li.hide()
  keycommands:
    prev: 37
    next: 39
  handle_key_command: (command) ->
    if command in ['prev', 'next']
      @get_another_page command
  keydownHandler: (event_object) =>
    for key, value of @keycommands
      if event_object.keyCode == value
        @handle_key_command key
  toggle_sort_direction: (event) ->
    icon = @ui.dir_icon
    if icon.hasClass 'fa-arrow-up'
      icon.removeClass 'fa-arrow-up'
      icon.addClass 'fa-arrow-down'
      @collection.state.sortDirection = 'desc'
    else
      icon.removeClass 'fa-arrow-down'
      icon.addClass 'fa-arrow-up'
      @collection.state.sortDirection = 'asc'
    response = @collection.fetch
      data:
        where: AppChannel.request 'locals:get', 'currentQueryWhere'
    response.done =>
      @collection.trigger 'pageable:state:change'

  onRender: ->
    # do setup
    @update_nav_buttons()
    @collection.on 'pageable:state:change', =>
      @update_nav_buttons()
    $('html').keydown @keydownHandler
    
  onBeforeDestroy: ->
    @collection.off 'pageable:state:change'
    $('html').unbind 'keydown', @keydownHandler

  get_another_page: (direction) ->
    # we need to add the where clause
    where = AppChannel.request 'locals:get', 'currentQueryWhere'
    @collection.queryParams.where = where
    currentPage = @collection.state.currentPage
    onLastPage = currentPage is @collection.state.lastPage
    response = undefined
    if direction is 'prev' and currentPage
      response = @collection.getPreviousPage()
    else if direction is 'next' and not onLastPage
      response = @collection.getNextPage()
    if response
      response.done =>
        # remove the where clause when done
        delete @collection.queryParams.where
    
  get_prev_page: () ->
    @get_another_page 'prev'
  get_next_page: () ->
    @get_another_page 'next'
      
    
module.exports = NavigateBox


