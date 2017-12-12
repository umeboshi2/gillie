Marionette = require 'backbone.marionette'
navigate_to_url = require 'tbirds/util/navigate-to-url'
isObjectEmpty = require 'tbirds/util/object-empty'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

class AdminRouter extends Marionette.AppRouter
  before: ->
    user = MainChannel.request 'main:app:decode-auth-token'
    if not isObjectEmpty user
      if 'admin' not in user.groups
        MessageChannel.request 'danger', 'Admin access only!'
        #navigate_to_url '/'
    return
    
module.exports = AdminRouter

