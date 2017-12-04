Backbone = require 'backbone'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

ComicAges =
  platinum:
    start: 1897
    end: 1937
  golden:
    start: 1938
    end: 1955
  silver:
    start: 1956
    end: 1969
  bronze:
    start: 1970
    end: 1983
  copper:
    start: 1984
    end: 1991
  modern:
    start: 1992
    # FIXME magic number for end of modern age
    end: 2100

get_comic_age = (year) ->
  for age of ComicAges
    ad = ComicAges[age]
    #console.log "Checking age", age, ad.start, ad.end
    if (year >= ad.start and year <= ad.end)
      return age
  return false
  
AppChannel.reply 'get-comic-ages', ->
  ComicAges

AppChannel.reply 'find-age', (year) ->
  get_comic_age year


get_heroes_by_age = (year, herolist) ->
  age = get_comic_age year
  newlist = []
  herolist.forEach (row) ->
    if row.age == age
      newlist.push row
  return newlist


AppChannel.reply 'get-heroes-by-age', (year, herolist) ->
  get_heroes_by_age year, herolist
  
module.exports = {}
