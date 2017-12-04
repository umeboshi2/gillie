set_product_upc = (row, options) ->
  comic = options.comic
  # set upc
  # if comic.isbn then set Product:UPC
  # if upc.length == 14 then return upc[:-2]
  # if upc.length == 13 then return upc[1:]
  if comic?.isbn
    upc = comic.isbn
    if upc.length == 14
      upc = upc.substring(0, upc.length - 2)
    if upc.length == 13
      upc = upc.substring(1, upc.length)
    row['Product:UPC'] = upc
    
module.exports = set_product_upc
