Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
marked = require 'marked'

class MarkdownView extends Marionette.View
  template: tc.renderable (model) ->
    tc.article '.document-view.content.col-sm-8.col-sm-offset-2', ->
      tc.div '.body', ->
        tc.raw marked model.content

module.exports = MarkdownView
