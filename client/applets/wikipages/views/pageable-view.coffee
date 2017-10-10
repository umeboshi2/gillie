Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
keycode = require 'keycode'

class HasPageableCollection extends Marionette.Behavior
  ui:
    prev_li: '.previous'
    next_li: '.next'
    prev_button: '.prev-page-button'
    next_button: '.next-page-button'
  events:
    'click @ui.prev_button': 'get_prev_page'
    'click @ui.next_button': 'get_next_page'
  keycommands:
    prev: keycode 'left'
    next: keycode 'right'
  handle_key_command: (command) ->
    if command in ['prev', 'next']
      @get_another_page command
  keydownHandler: (event_object) =>
    for key, value of @keycommands
      if event_object.keyCode == value
        @handle_key_command key
  update_nav_buttons: ->
    collection = @view.getOption 'collection'
    currentPage = collection.state.currentPage
    if currentPage
      @ui.prev_li.show()
    else
      @ui.prev_li.hide()
    if currentPage != collection.state.lastPage
      @ui.next_li.show()
    else
      @ui.next_li.hide()
    if collection.state.totalRecords is 0
      @ui.prev_li.hide()
      @ui.next_li.hide()

  onRender: ->
    # do setup
    @update_nav_buttons()
    collection = @view.getOption 'collection'
    collection.on 'pageable:state:change', =>
      @update_nav_buttons()
    $('html').keydown @keydownHandler
    
  onBeforeDestroy: ->
    collection = @view.getOption 'collection'
    collection.off 'pageable:state:change'
    $('html').unbind 'keydown', @keydownHandler

  get_another_page: (direction) ->
    collection = @view.getOption 'collection'
    currentPage = collection.state.currentPage
    onLastPage = currentPage is collection.state.lastPage
    response = undefined
    if direction is 'prev' and currentPage
      response = collection.getPreviousPage()
    else if direction is 'next' and not onLastPage
      response = collection.getNextPage()
    if response
      response.done =>
        # remove the where clause when done
        delete collection.queryParams.where
    
  get_prev_page: () ->
    @get_another_page 'prev'
  get_next_page: () ->
    @get_another_page 'next'
      
    
  
module.exports = HasPageableCollection
