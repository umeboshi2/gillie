Backbone = require 'backbone'

require './csvrow-main'
require './xmlparser'

AppChannel = Backbone.Radio.channel 'sofi'

AppChannel.reply 'fix-image-url', (img) ->
  # check if this is clz large image
  if img.indexOf '/lg/'
    img = img.replace '/lg/', '/sm/'
  # make url protocol agnostic
  if img.startsWith 'http://'
    img = img.replace 'http://', '//'
  return img
  
