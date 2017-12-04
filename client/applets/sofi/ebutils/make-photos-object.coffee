module.exports = (comic) ->
  photos = {}
  comic.photos.forEach (prow) ->
    photos[prow.name] = prow.filename
  return photos

