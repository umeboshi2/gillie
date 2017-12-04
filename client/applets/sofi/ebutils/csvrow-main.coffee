Backbone = require 'backbone'
xml = require 'xml2js-parseonly/src/xml2js'
ms = require 'ms'
dateFormat = require 'dateformat'
handlebars = require 'handlebars'
marked = require 'marked'

capitalize = require 'tbirds/util/capitalize'

require './csv-header'

set_startprice = require './csvfield-startprice'
set_scheduletime = require './csvfield-scheduletime'
set_product_upc = require './csvfield-product-upc'
set_category_id = require './csvfield-category-id'
set_pic_url = require './csvfield-picurl'
set_title_and_desc = require './csvfield-title-desc'


MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

gfields = AppChannel.request 'grouped-csv-fields'

#######################################################
# makeCommonData (config)
#######################################################

create_common_data = (options) ->
  row = {}
  cfg = options.cfg.get 'content'
  row.action = options.action
  gfields.ReqFieldNames.forEach (field) ->
    row[field] = cfg[field]
  gfields.OptFieldNames.forEach (field) ->
    row[field] = cfg[field]
  gfields.EbayFields.forEach (field) ->
    row[field] = ''
  return row
  
#######################################################
# makeEbayInfo (config, comic, opts, mgr)
#######################################################
create_csv_row_object = (options) ->
  #console.log "CREATE_CSV_ROW_OBJECT", options
  comic = options.comic
  clzcomic = comic.content
  if typeof clzcomic is 'string'
    clzcomic = JSON.parse clzcomic
  options.clzcomic = clzcomic
  #console.log "CLZCOMIC", clzcomic
  photos = {}
  comic.photos.forEach (pRow) ->
    photos[pRow.name] = pRow.filename
  console.log "PHOTOS", photos, comic
  options.photos = photos
  cfg = options.cfg.get 'content'
  # make common data
  # from required and optional fields
  row = create_common_data options
  # then adjust these fields -->

  # quantity is from config(1) unless comic.quantity > 1
  # csv header should be *Quantity
  if row.quantity != clzcomic.quantity
    row.quantity = clzcomic.quantity

  # set startprice
  set_startprice row, options

  # set scheduletime
  set_scheduletime row, options
  
  #
  # --------> then add fields

  set_product_upc row, options

  
  set_category_id row, options

  # set picurl
  set_pic_url row, options

  
  # remove <br>'s from plot before
  # using templates
  if comic.mainsection?.plot
    comic.mainsection.plot = comic.mainsection.plot.split('<br>').join('\n')
    comic.mainsection.plot = comic.mainsection.plot.split('<BR>').join('\n')

  set_title_and_desc row, options
  return row

AppChannel.reply 'create-csv-row-object', (options) ->
  create_csv_row_object options

module.exports = {}
