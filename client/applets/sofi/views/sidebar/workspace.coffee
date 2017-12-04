$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

{ form_group_input_div } = require 'tbirds/templates/forms'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

AuthCollection = MainChannel.request 'main:app:AuthCollection'
apiroot = "/api/dev/bapi"

WorkspaceCollection = AppChannel.request(
  'db:ebcomicworkspace:WorkspaceCollection')

class WorkspaceView extends Marionette.View
  initialize: ->
    @collection = new WorkspaceCollection
    response = @collection.fetch
      data:
        distinct: 'name'
        sort: 'name'
    response.done => @render()
    
  className: 'listview-list-entry'
  ui:
    name_input: 'select[name="select_workspace"]'
  triggers:
    'change @ui.name_input': 'workspace:changed'
  templateContext: ->
    collection: @collection
  theWorkspaceChanged: (event) ->
    console.log 'theWorkspaceChanged', event
    
  template: tc.renderable (model) ->
    form_group_input_div
      input_id: "input_wsname"
      label: 'Workspace Name'
      input_attributes:
        name: "name"
    tc.span '.input-group', ->
      tc.label '.control-label', for:'select_workspace',
      'Workspace'
      tc.select '.form-control', name:'select_workspace', ->
        tc.option value:"UNATTACHED", 'Unattached Comics'
        if not model.items.length
          #tc.option value:'current', selected:'', 'Current'
          console.log "No workspaces!"
        else
          for item in model.items
            opts = value: item.name
            tc.option opts, item.name
      
module.exports = WorkspaceView
