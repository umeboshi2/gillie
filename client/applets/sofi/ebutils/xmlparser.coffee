Backbone = require 'backbone'
xml = require 'xml2js-parseonly/src/xml2js'
ms = require 'ms'
dateFormat = require 'dateformat'
handlebars = require 'handlebars'
marked = require 'marked'

capitalize = require 'tbirds/util/capitalize'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

XmlParser = new xml.Parser
  explicitArray: false
  async: false

AppChannel.reply 'get-xmlparser', ->
  XmlParser
  

class XmlComic extends Backbone.Model

class XmlComicCollection extends Backbone.Collection
  model: XmlComic

CurrentCollection = new XmlComicCollection

AppChannel.reply 'set-comics', (comics) ->
  CurrentCollection.set comics

AppChannel.reply 'get-comics', ->
  CurrentCollection

AppChannel.reply 'parse-all-comics-xml', (content, cb) ->
  XmlParser.parseString content, (err, json) ->
    comics = json.comicinfo.comiclist.comic
    #if __DEV__
    #  window.Comics = comics
    #  console.log "Comics", comics
    if not comics?.length
      console.warn "Single comic!"
      comics = [comics]
    AppChannel.request 'set-comics', comics
    cb()
    
AppChannel.reply 'parse-comics-xml', (content, cb) ->
  XmlParser.parseString content, (err, json) ->
    comics = json.comicinfo.comiclist.comic
    #if __DEV__
    #  window.Comics = comics
    #  console.log "Comics", comics
    if not comics?.length
      #console.warn "Single comic!"
      comics = [comics]
    forsale = []
    in_collection = []
    bad_xml = []
    for comic in comics
      #console.log comic.collectionstatus
      status = comic.collectionstatus._
      if status == 'For Sale'
        if not comic.links
          bad_xml.push comic
        else
          forsale.push comic
      else if status == 'In Collection'
        in_collection.push comic
      else
        main = comic.mainsection
        name = "#{main.series.displayname} ##{main.issue}"
        msg = "Cannot determine comic status of (#{name})!"
        MessageChannel.request "danger", msg
    if in_collection.length
      msg = "#{in_collection.length} ignored!!"
      MessageChannel.request "warning", msg
    if not forsale.length
      MessageChannel.request "danger", "No comics for sale!"
    if bad_xml.length
      msg = "There was some bad xml, skipped #{bad_xml.length} comics."
      MessageChannel.request 'danger', msg
    AppChannel.request 'set-comics', forsale
    cb()


module.exports = {}
