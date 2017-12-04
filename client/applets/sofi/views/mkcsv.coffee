Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ form_group_input_div } = require 'tbirds/templates/forms'

ComicEntryView = require './comic-entry'
ComicListView = require './comic-list'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'


mkInputData = (field, label, placeholder) ->
  input_id: "input_#{field}"
  label: label
  input_attributes:
    name: field
    placeholder: placeholder

csvActionSelect = tc.renderable () ->
  tc.div '.form-group', ->
    tc.label '.control-label', for:'select_action', 'Action'
  tc.select '.form-control', name:'select_action', ->
    for action in ['Add', 'VerifyAdd']
      tc.option selected:null, value:action, action
    
csvCfgSelect = tc.renderable (collection) ->
  tc.div '.form-group', ->
    tc.label '.control-label', for:'select_cfg', 'Config'
  tc.select '.form-control', name:'select_cfg', ->
    for m in collection.models
      name = m.get 'name'
      options =
        value:m.id
      if name is 'default'
        options.selected = ''
      tc.option options, name
    
csvDscSelect = tc.renderable (collection) ->
  tc.div '.form-group', ->
    tc.label '.control-label', for:'select_dsc', 'Description'
  tc.select '.form-control', name:'select_dsc', ->
    for m in collection.models
      name = m.get 'name'
      options =
        value:m.id
      if name is 'default'
        options.selected = ''
      tc.option options, name

WorkspaceCollection = AppChannel.request(
  'db:ebcomicworkspace:WorkspaceCollection')

class WorkspaceSelect extends Marionette.View
  initialize: ->
    @collection = new WorkspaceCollection
    response = @collection.fetch
      data:
        distinct: 'name'
        sort: 'name'
    response.done => @render()
  ui:
    name_input: 'select[name="select_workspace"]'
  triggers:
    'change @ui.name_input': 'workspace:changed'
  templateContext: ->
    collection: @collection
  template: tc.renderable (model) ->
    tc.span '.input-group', ->
      tc.label '.control-label', for:'select_workspace',
      'Workspace'
      tc.select '.form-control', name:'select_workspace', ->
        if not model.items.length
          console.log "No workspaces!"
        else
          for item in model.items
            opts = value: item.name
            tc.option opts, item.name
      
  
########################################
class ComicsView extends Backbone.Marionette.View
  ui:
    mkcsv_btn: '.mkcsv-button'
    show_btn: '.show-comics-button'
    action_sel: 'select[name="select_action"]'
    cfg_sel: 'select[name="select_cfg"]'
    dsc_sel: 'select[name="select_dsc"]'
    workspaceSelect: '.workspace-select'
    body: '.body'
  regions:
    body: '@ui.body'
    workspaceSelect: '@ui.workspaceSelect'
  events:
    'click @ui.mkcsv_btn': 'makeCsv'
    'click @ui.show_btn': 'showComics'
  templateContext: ->
    options = @options
    options.ebcfgCollection = AppChannel.request 'db:ebcfg:collection'
    options.ebdscCollection = AppChannel.request 'db:ebdsc:collection'
    options
  template: tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text "Create CSV"
    tc.div '.mkcsv-form', ->
      csvActionSelect()
      csvCfgSelect model.ebcfgCollection
      csvDscSelect model.ebdscCollection
      tc.div '.workspace-select'
    tc.hr()
    tc.div '.mkcsv-button.btn.btn-default', "Preview CSV Data"
    tc.div '.show-comics-button.btn.btn-default', "Show Comics"
    tc.div '.body'
  onRender: ->
    view = new WorkspaceSelect
    @showChildView 'workspaceSelect', view
    
  makeCsv: ->
    action = @ui.action_sel.val()
    cfg = AppChannel.request 'db:ebcfg:get', @ui.cfg_sel.val()
    dsc = AppChannel.request 'db:ebdsc:get', @ui.dsc_sel.val()
    wsview = @getChildView 'workspaceSelect'
    workspace = wsview.ui.name_input.val()
    console.log "makeCsv workspace", workspace
    AppChannel.request 'locals:set', 'currentCsvWorkspace', workspace
    AppChannel.request 'locals:set', 'currentCsvAction', action
    AppChannel.request 'locals:set', 'currentCsvCfg', cfg
    AppChannel.request 'locals:set', 'currentCsvDsc', dsc
    navigate_to_url '#sofi/csv/preview'
    
  showComics: ->
    view = new ComicListView
      collection: @collection
    @showChildView 'body', view
    
module.exports = ComicsView


