_ = require 'underscore'
Backbone = require 'backbone'
moment = require 'moment'
DbCollection = require 'tbirds/dbcollection'
{ LocalStorage } = require 'backbone.localstorage'

MainChannel = Backbone.Radio.channel 'global'
AppChannel = Backbone.Radio.channel 'sofi'

AuthModel = MainChannel.request 'main:app:AuthModel'
AuthCollection = MainChannel.request 'main:app:AuthCollection'

apiroot = "/api/dev/bapi/sofi"
cfg_apipath = "#{apiroot}/ebcsvcfg"
dsc_apipath = "#{apiroot}/ebcsvdsc"

defaultOptions =
  channelName: 'sofi'
  
class SuperHeroList extends Backbone.Model
  url: '/assets/data/superheroes.json'

hero_list = new SuperHeroList
AppChannel.reply 'get-superheroes-model', ->
  hero_list

class BaseLocalStorageModel extends Backbone.Model
  initialize: () ->
    @fetch()
    @on 'change', @save, @
  fetch: () ->
    #console.log '===== FETCH FIRED LOADING LOCAL STORAGE ===='
    @set JSON.parse localStorage.getItem @id
  save: (attributes, options) ->
    #console.log '===== CHANGE FIRED SAVING LOCAL STORAGE ===='
    localStorage.setItem(@id, JSON.stringify(@toJSON()))
    #return $.ajax
    #  success: options.success
    #  error: options.error
  destroy: (options) ->
    #console.log '===== DESTROY LOCAL STORAGE ===='
    localStorage.removeItem @id
  isEmpty: () ->
    _.size @attributes <= 1



class ComicPhotoNames extends Backbone.Collection
  localStorage: new LocalStorage 'ComicPhotoNames'

AppChannel.reply 'ComicPhotoNames', ->
  ComicPhotoNames


  
AppChannel.reply 'get-comic-image-urls', ->
  comic_image_urls = new BaseLocalStorageModel
    id: 'comic-image-urls'
  comic_image_urls.toJSON()

AppChannel.reply 'add-comic-image-url', (url, image_src) ->
  comic_image_urls = new BaseLocalStorageModel
    id: 'comic-image-urls'
  comic_image_urls.set url, image_src
  #comic_image_urls.save()
  
AppChannel.reply 'clear-comic-image-urls', ->
  comic_image_urls = new BaseLocalStorageModel
    id: 'comic-image-urls'
  comic_image_urls.destroy()
  #delete localStorage[comic_image_urls.id]
  console.log "localStorage", localStorage[comic_image_urls.id]
  
class EbConfigModel extends AuthModel
  urlRoot: cfg_apipath
  parse: (response, options) ->
    if typeof(response.content) is 'string'
      response.content = JSON.parse response.content
    super response, options
    
class EbConfigCollection extends AuthCollection
  url: cfg_apipath
  model: EbConfigModel

dbcfg = new DbCollection _.extend defaultOptions,
  modelName: 'ebcfg'
  modelClass: EbConfigModel
  collectionClass: EbConfigCollection

class EbDescModel extends AuthModel
  urlRoot: dsc_apipath

class EbDescCollection extends AuthCollection
  url: dsc_apipath
  model: EbDescModel

dbdsc = new DbCollection _.extend defaultOptions,
  modelName: 'ebdsc'
  modelClass: EbDescModel
  collectionClass: EbDescCollection

class ClzPage extends AuthModel
  urlRoot: "#{apiroot}/ebclzpage"
  parse: (response, options) ->
    console.warn "ClzPage is deprecated"
    if typeof(response.clzdata) is 'string'
      response.clzdata = JSON.parse response.clzdata
    super response, options

class ClzPageCollection extends AuthCollection
  fetch: (options) ->
    console.warn "ClzPageCollection is deprecated"
    super options
    
  url: "#{apiroot}/ebclzpage"
  model: ClzPage

dbclzpage = new DbCollection _.extend defaultOptions,
  modelName: 'clzpage'
  modelClass: ClzPage
  collectionClass: ClzPageCollection
  
# get all except content
dbComicColumns = ['id', 'comic_id', 'list_id', 'bpcomicid',
  'bpseriesid', 'rare', 'publisher', 'releasedate',
  'seriesgroup', 'series', 'issue', 'issueext', 'quantity',
  'currentprice', 'url', 'image_src', 'created_at', 'updated_at']

AppChannel.reply 'dbComicColumns', ->
  dbComicColumns

clzComicRelated = ['collectionStatus', 'photos', 'workspace']
clzComicExtra = ['ReleaseDate']

class ClzComic extends AuthModel
  urlRoot: "#{apiroot}/ebclzcomic"
  parse: (response, options) ->
    if typeof(response.content) is 'string'
      response.content = JSON.parse response.content
    if typeof(response.releasedate) is 'string'
      m = moment(response.releasedate)
      response.ReleaseDate = m.format('ddd MMM DD, YYYY')
    super response, options
  fetch: (options) ->
    # FIXME this is messy, do we need to go through this
    # trouble?  We hardly ever set fetch options on a
    # single model.
    options = options or {}
    options.data = options.data or {}
    if not options.data?.withRelated
      options.data.withRelated = clzComicRelated
    super options
  save: (attrs, options) ->
    pruneFields = clzComicRelated.concat clzComicExtra
    pruneFields.forEach (attribute) =>
      if @has attribute
        @unset attribute
    super attrs, options
    
class ClzComicCollection extends AuthCollection
  url: "#{apiroot}/ebclzcomic"
  model: ClzComic
  fetch: (options) ->
    options = options or {}
    options.data = options.data or {}
    if not options.data?.withRelated
      options.data.withRelated = clzComicRelated
    super options
    
    
dbclzcomic = new DbCollection _.extend defaultOptions,
  modelName: 'clzcomic'
  modelClass: ClzComic
  collectionClass: ClzComicCollection


class SeriesGroupCollection extends AuthCollection
  url: "#{apiroot}/ebclzcomic"
  model: AppChannel.request 'db:clzcomic:modelClass'
  state:
    firstPage: 0
    # FIXME
    pageSize: 10000
    sortColumn: 'seriesgroup'
    sortDirection: 'asc'

AppChannel.reply 'db:clzcomic:SeriesGroupCollection', ->
  SeriesGroupCollection
  
class PublisherCollection extends AuthCollection
  url: "#{apiroot}/ebclzcomic"
  model: AppChannel.request 'db:clzcomic:modelClass'
  state:
    firstPage: 0
    # FIXME
    pageSize: 10000
    sortColumn: 'publisher'
    sortDirection: 'asc'

AppChannel.reply 'db:clzcomic:PublisherCollection', ->
  PublisherCollection
  
class ClzCollectionStatus extends AuthModel
  urlRoot: "#{apiroot}/clzcollectionstatus"

class ClzCollectionStatusCollection extends AuthCollection
  url: "#{apiroot}/clzcollectionstatus"
  model: ClzCollectionStatus
  
dbclzcomic = new DbCollection _.extend defaultOptions,
  modelName: 'clzcollectionstatus'
  modelClass: ClzCollectionStatus
  collectionClass: ClzCollectionStatusCollection

workspaceRelated = ['comic']
workspaceExtra = []
class WorkspaceComic extends AuthModel
  urlRoot: "#{apiroot}/ebcomicworkspace"
  save: (attrs, options) ->
    pruneFields = workspaceRelated.concat workspaceExtra
    pruneFields.forEach (attribute) =>
      if @has attribute
        @unset attribute
    super attrs, options

class WorkspaceComics extends AuthCollection
  url: "#{apiroot}/ebcomicworkspace"
  model: WorkspaceComic
  fetch: (options) ->
    options = options or {}
    options.data = options.data or {}
    if not options.data?.withRelated
      options.data.withRelated = workspaceRelated
    super options

dbwscomic = new DbCollection _.extend defaultOptions,
  modelName: 'ebcomicworkspace'
  modelClass: WorkspaceComic
  collectionClass: WorkspaceComics



class WorkspaceCollection extends AuthCollection
  url: "#{apiroot}/ebcomicworkspace"
  model: AppChannel.request 'db:clzcomic:modelClass'
  state:
    firstPage: 0
    # FIXME
    pageSize: 10000
    sortColumn: 'name'
    sortDirection: 'asc'

AppChannel.reply 'db:ebcomicworkspace:WorkspaceCollection', ->
  WorkspaceCollection
    

class UnattachedCollection extends AuthCollection
  url: "/api/dev/misc/unattached-comics"
  model: ClzComic

AppChannel.reply 'db:unattached:collectionClass', ->
  UnattachedCollection



class ComicPhotoName extends AuthModel
  urlRoot: "#{apiroot}/comicphotoname"

class ComicPhotoNameCollection extends AuthCollection
  url: "#{apiroot}/comicphotoname"
  model: ComicPhotoName
  
dbclzcomic = new DbCollection _.extend defaultOptions,
  modelName: 'comicphotoname'
  modelClass: ComicPhotoName
  collectionClass: ComicPhotoNameCollection
  




AppletLocals = {}
AppChannel.reply 'locals:get', (name) ->
  AppletLocals[name]
AppChannel.reply 'locals:set', (name, value) ->
  AppletLocals[name] = value
AppChannel.reply 'locals:delete', (name) ->
  delete AppletLocals[name]

AppChannel.request 'locals:set', 'currentQueryWhere', {}

  
module.exports =
  EbConfigCollection: EbConfigCollection
  EbDescCollection: EbDescCollection
  ClzPageCollection: ClzPageCollection
  
