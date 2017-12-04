set_startprice = (row, options) ->
  # default startprice in config
  # csv header should be *Startprice
  # if comic.currentprice exists use
  # that instead
  comic = options.clzcomic
  if comic?.currentprice
    currentprice = comic.currentprice
    while currentprice.startsWith '$'
      currentprice = currentprice.substring 1, currentprice.length
    row.startprice = currentprice
  
module.exports = set_startprice
