$= require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
Backbone.Relational = require 'backbone-relational'

require 'backbone.routefilter'
Marionette = require 'backbone.marionette'

# setup backbone relational and jsonapi
#brjs = require 'backbone-relational-sync-jsonapi'
#brjs.default Backbone, _

#brj = require 'backbone-relational-jsonapi'
#brj.default Backbone, _


require 'bootstrap'

if __DEV__
  console.warn "__DEV__", __DEV__, "DEBUG", DEBUG
  Backbone.Radio.DEBUG = true

require 'tbirds/applet-router'
IsEscapeModal = require 'tbirds/behaviors/is-escape-modal'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'

# set pagesize before requiring authmodels
if localStorage.getItem('page-size') is null
  localStorage.setItem 'page-size', 10

MainChannel.reply 'main:app:set-pagesize', (pagesize) ->
  localStorage.setItem 'page-size', pagesize

MainChannel.reply 'main:app:get-pagesize', ->
  localStorage.getItem 'page-size'

if __DEV__
  require '../inspector'
#require '../authmodels'
require '../crud'
require '../static-documents'
#require '../site-schema'


MainChannel.reply 'main:app:switch-theme', (theme) ->
  href = "/assets/stylesheets/bootstrap-#{theme}.css"
  ss = $ 'head link[href^="/assets/stylesheets/bootstrap-"]'
  ss.attr 'href', href

MainChannel.reply 'main:app:set-theme', (theme) ->
  localStorage.setItem 'main-theme', theme

MainChannel.reply 'main:app:get-theme', ->
  localStorage.getItem 'main-theme'

  
export_to_file = (options) ->
  data = encodeURIComponent(options.data)
  link = "#{options.type},#{data}"
  filename = options.filename or "exported"
  a = document.createElement 'a'
  a.id = options.el_id or 'exported-file-anchor'
  a.href = link
  a.download = filename
  a.innerHTML = "Download #{filename}"
  a.style.display = 'none'
  document.body.appendChild a
  a.click()
  document.body.removeChild a
  
MainChannel.reply 'export-to-file', (options) ->
  export_to_file options
  

class BaseModalView extends Marionette.View
  behaviors: [IsEscapeModal]
  ui:
    close_btn: '#close-modal div'
    
MainChannel.reply 'main:app:BaseModalView', ->
  BaseModalView
  
show_modal = (view, backdrop=false) ->
  app = MainChannel.request 'main:app:object'
  modal_region = app.getView().getRegion 'modal'
  modal_region.backdrop = backdrop
  modal_region.show view

MainChannel.reply 'show-modal', (view, backdrop=false) ->
  console.warn 'show-modal', backdrop
  show_modal view, false
  


module.exports = {}



