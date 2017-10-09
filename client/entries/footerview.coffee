Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
jwtDecode = require 'jwt-decode'
ms = require 'ms'

navigate_to_url = require 'tbirds/util/navigate-to-url'
TopApp = require 'tbirds/top-app'

require './base'
pkg = require '../../package.json'
pkgmodel = new Backbone.Model pkg

MainAppConfig = require './index-config'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

class FooterView extends Marionette.View
  template: tc.renderable (model) ->
    version_style = '.col-sm-2.col-sm-offset-10'
    timestyle = '.col-sm-2.col-sm-offset-1'
    tc.div '.col-sm-10.col-sm-offset-1', ->
      tc.table '.table', ->
        tc.tr ->
          if model.remaining >= 0
            seconds_in_day = 24 * 60 * 60
            days = Math.floor(model.remaining / seconds_in_day)
            tc.td "#{days} days left for #{model.token.name}"
          else
            tc.td "Time expired for #{model.token.name}"
          tc.td "Version: #{model.version}"
            
  
module.exports = FooterView



