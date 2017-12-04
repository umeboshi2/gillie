Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'

BootstrapFormView = require 'tbirds/views/bsformview'
capitalize = require 'tbirds/util/capitalize'
make_field_input_ui = require 'tbirds/util/make-field-input-ui'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ form_group_input_div } = require 'tbirds/templates/forms'

MainChannel = Backbone.Radio.channel 'global'

# FIXME, make a css manifest
themes = [
  'vanilla'
  'cornsilk'
  'BlanchedAlmond'
  'DarkSeaGreen'
  'LavenderBlush'
  ]

config_template = tc.renderable (model) ->
  current_theme = MainChannel.request 'main:app:get-theme'
  tc.div '.form-group', ->
    tc.label '.control-label',
      for: 'select_theme'
      "Theme"
    tc.select '.form-control', name:'select_theme', ->
      for opt in themes
        if opt is current_theme
          tc.option selected:null, value:opt, opt
        else
          tc.option value:opt, opt
  form_group_input_div
    input_id: 'input_pagesize'
    label: 'Page Size'
    input_attributes:
      name: 'pagesize'
      value: MainChannel.request 'main:app:get-pagesize'
  tc.input '.btn.btn-default', type:'submit', value:"Submit"
  tc.div '.spinner.fa.fa-spinner.fa-spin'

class UserConfigView extends BootstrapFormView
  template: config_template
  ui:
    theme: 'select[name="select_theme"]'
    pagesize: 'input[name="pagesize"]'
  createModel: ->
    @model
    
  updateModel: ->
    config = @model.get 'config'
    changed_config = false
    selected_theme = @ui.theme.val()
    MainChannel.request 'main:app:set-theme', selected_theme
    oldsize = MainChannel.request 'main:app:get-pagesize'
    pagesize = @ui.pagesize.val()
    MainChannel.request 'main:app:set-pagesize', pagesize
    if oldsize != pagesize
      navigate_to_url '/'
    
  saveModel: ->
    theme = MainChannel.request 'main:app:get-theme'
    MainChannel.request 'main:app:switch-theme', theme
    @trigger 'save:form:success', @model
    
    
  onSuccess: (model) ->
    navigate_to_url '#profile'
    

module.exports = UserConfigView

