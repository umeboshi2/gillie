Backbone = require 'backbone'

require '../dbchannel'
require './comic-ages'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'


set_category_id = (row, options) ->
  comic = options.clzcomic
  #
  # get categoryID
  # csv header should be *Category
  shmodel = AppChannel.request 'get-superheroes-model'
  hlist = shmodel.get 'rows'
  # FIXME this might fail and year needs to be 2017
  year = comic.publicationdate?.year
  if not year
    year = comic.releasedate.year
    console.warn "Using releasedate"
  if not year
    console.warn "Bad date for comic", comic
    MessageChannel.request "danger", "Bad Date for comic #{comic.id}"
  year = parseInt year.displayname
  #console.log "YEAR", year
  seriesname = comic.mainsection.series.displayname.toLowerCase()
  age = AppChannel.request 'find-age', year
  hrows = AppChannel.request 'get-heroes-by-age', year, hlist
  other_row = undefined
  heroes = {}
  for hrow in hrows
    if hrow.superhero.startsWith 'Other '
      other_row = hrow
    field = hrow.superhero.toLowerCase()
    heroes[field] = hrow
  if not other_row?
    MessageChannel.request 'danger', "No category found for #{age}"
  found_row = other_row
  for h of heroes
    #console.log "Checking hero", h, seriesname
    if (seriesname.indexOf(h) >= 0)
      found_row = heroes[h]
      break
  row['*Category'] = found_row.id
  
module.exports = set_category_id
