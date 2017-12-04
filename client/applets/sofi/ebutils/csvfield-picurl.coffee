Backbone = require 'backbone'

require '../dbchannel'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'


set_pic_url = (row, options) ->
  comic = options.comic
  #urls = AppChannel.request 'get-comic-image-urls'
  #url = comic.links.link.url
  #options.image_src = urls[url].replace 'http://', '//'
  #row['PicURL'] = urls[comic.links.link.url]
  row['PicURL'] = comic.image_src
  
module.exports = set_pic_url
