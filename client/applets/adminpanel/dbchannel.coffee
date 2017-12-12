_ = require 'underscore'
Backbone = require 'backbone'
moment = require 'moment'
DbCollection = require 'tbirds/dbcollection'
{ LocalStorage } = require 'backbone.localstorage'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'useradmin'
window.AppChannel = AppChannel

AuthModel = MainChannel.request 'main:app:AuthModel'
AuthCollection = MainChannel.request 'main:app:AuthCollection'


defaultOptions =
  channelName: 'useradmin'

apiroot = "/api/admin/jsonapi"
apiroot = "/api/dev/bapi/useradmin"

usersUrl = "#{apiroot}/users"
class UserModel extends AuthModel
  urlRoot: usersUrl

class UserCollection extends AuthCollection
  url: usersUrl
  model: UserModel

dbcfg = new DbCollection _.extend defaultOptions,
  modelName: 'user'
  modelClass: UserModel
  collectionClass: UserCollection




AppletLocals = {}
AppChannel.reply 'locals:get', (name) ->
  AppletLocals[name]
AppChannel.reply 'locals:set', (name, value) ->
  AppletLocals[name] = value
AppChannel.reply 'locals:delete', (name) ->
  delete AppletLocals[name]

  
module.exports = {}
