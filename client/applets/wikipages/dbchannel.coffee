Backbone = require 'backbone'

{ make_dbchannel } = require 'tbirds/crud/basecrudchannel'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'wikipages'

AuthModel = MainChannel.request 'main:app:AuthModel'
AuthCollection = MainChannel.request 'main:app:AuthCollection'


apiroot = "/api/dev/bsapi/main"
url = "#{apiroot}/wikipages"


class WikiPage extends AuthModel
  urlRoot: url

class WikiPageCollection extends AuthCollection
  url: url
  model: WikiPage

wikipage_collection = new WikiPageCollection()

make_dbchannel AppChannel, 'wikipage', WikiPage, WikiPageCollection

module.exports =
  WikiPageCollection: WikiPageCollection
