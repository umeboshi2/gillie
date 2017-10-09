Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
marked = require 'marked'

{ navigate_to_url } = require 'tbirds/util/navigate-to-url'

view_template = tc.renderable (model) ->
  tc.div '.row.listview-list-entry', ->
    tc.span "Name: #{model.name}"
    tc.br()
    tc.span "Description"
    tc.br()
    tc.div -> tc.raw model.content
    tc.span ".glyphicon.glyphicon-grain"
    
class MainView extends Backbone.Marionette.View
  template: view_template
    
module.exports = MainView

