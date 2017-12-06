# https://stackoverflow.com/a/32108184
module.exports = (obj) ->
  (Object.keys(obj).length == 0 && obj.constructor == Object)
