ms = require 'ms'
dateFormat = require 'dateformat'

set_scheduletime = (row, options) ->
  # parse scheduletime in config
  # if scheduletime is 0 then
  # set row.scheduletime = ''
  timedelta = ms row.scheduletime
  if timedelta
    now = new Date()
    nt = now.valueOf() + timedelta
    later = new Date nt
    #pyformat = "%Y-%m-%d %H:%M:%S"
    sformat = "yyyy-mm-dd HH:MM:ss"
    row.scheduletime = dateFormat later, sformat
  else
    row.scheduletime = ''
  
module.exports = set_scheduletime
