Backbone = require 'backbone'
handlebars = require 'handlebars'
marked = require 'marked'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'


set_title_and_desc = (row, options) ->
  comic = options.comic
  clzcomic = options.clzcomic
  photos = comic.photos
  dsc = options.desc
  # make title
  template = handlebars.compile dsc.get 'title'
  title = template options
  #console.log 'title', title
  if title.length > 80
    msg = "Title too long.\n"
    newtitle = title.substring(0, 79)
    msg = msg + "#{title} ----> #{newtitle}"
    MessageChannel.request 'danger', msg
    title = newtitle
  row['Title'] = title
  
  # make description
  template = handlebars.compile dsc.get 'content'
  description = template options
  description = marked description
  # https://stackoverflow.com/a/17606289
  description = description.split('\r').join('')
  description = description.split('\n').join('')
  if description.length > 32700
    msg = "#{description.length} characters in description"
    MessageChannel.request 'warning', msg
  if '\n' in description
    MessageChannel.request 'danger', 'newline in description'
  row['Description'] = description

module.exports = set_title_and_desc
