$ = require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

class StaticDocument extends Backbone.Model
  url: ->
    "/assets/documents/#{@id}.md"
  
  fetch: (options) ->
    options = _.extend options || {},
      dataType: 'text'
    super options

  parse: (response) ->
    return content: response
    
  
MainChannel.reply 'main:app:get-document', (name) ->
  model = new StaticDocument
    id: name


  
module.exports =
  StaticDocument: StaticDocument
  
