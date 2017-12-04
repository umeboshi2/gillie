moment = require 'moment'
            
parseReleaseDate = (releasedate) ->
  if not releasedate
    releasedate = null
    return releasedate
  else if '/' in releasedate
    if releasedate.split('/').length is 3
      return moment releasedate, 'M/D/YYYY'
    else
      errmsg = "Couldn't parse #{releasedate}!"
      throw new Error "Couldn't parse #{releasedate}!"
  else if (typeof releasedate is 'string') and (releasedate.length is 4)
    fakedate = "1/1/#{releasedate}"
    return moment fakedate, 'M/D/YYYY'
  else
    format = "MMM YYYY"
    rdate = moment releasedate, format
    #console.log "MMM YYYY", rdate.toString()
    return rdate
  
module.exports = parseReleaseDate
