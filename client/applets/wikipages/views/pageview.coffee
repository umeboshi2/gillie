Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
marked = require 'marked'

{ navigate_to_url } = require 'tbirds/util/navigate-to-url'

# start with 100%
current_font_size = 100


view_template = tc.renderable (model) ->
  tc.div '.row.listview-list-entry.text-center', ->  
    tc.strong model.name
  tc.div '.zoom-out.btn.btn-default.fa.fa-minus'
  tc.div '.zoom-in.btn.btn-default.fa.fa-plus'
  tc.div '.row.listview-list-entry', ->
    tc.div '.wikipage', style:"font-size: #{current_font_size}%;", ->
      tc.raw model.content

    
class MainView extends Backbone.Marionette.View
  template: view_template
  ui:
    wikipage: '.wikipage'
    zoomIn: '.zoom-in'
    zoomOut: '.zoom-out'
  events:
    'click @ui.zoomIn': 'zoomInPage'
    'click @ui.zoomOut': 'zoomOutPage'

  zoomInPage: ->
    if current_font_size <= 500
      current_font_size += 10
    @ui.wikipage.css
      'font-size': "#{current_font_size}%"
  zoomOutPage: ->
    if current_font_size >= 30
      current_font_size -= 10
    @ui.wikipage.css
      'font-size': "#{current_font_size}%"
    
module.exports = MainView

