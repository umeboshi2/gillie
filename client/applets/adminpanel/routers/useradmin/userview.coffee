Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
tc = require 'teacup'
marked = require 'marked'

BootstrapFormView = require 'tbirds/views/bsformview'
navigate_to_url = require 'tbirds/util/navigate-to-url'
{ form_group_input_div } = require 'tbirds/templates/forms'

MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'useradmin'


dsc_template = tc.renderable (model) ->
  tc.div '.listview-header', ->
    tc.text "Viewing User #{model.username}"
  tc.hr()
  tc.a href:'#adminpanel/users/list', 'List Users'
  tc.article '.document-view.content', ->
    tc.div '.body', ->
      tc.text "This is #{model.fullname}"
  

########################################
class UserView extends Backbone.Marionette.View
  template: dsc_template
  ui:
    copy_btn: '.copy-btn'
    edit_btn: '.edit-btn'
    destname_input: 'input[name="destname"]'
  events:
    'click @ui.copy_btn': 'copy_user'
    'click @ui.edit_btn': 'edit_user'
  edit_user: ->
    navigate_to_url "#adminpanel/users/edit/#{@model.id}"
  copy_user: ->
    foo = 'bar'
    MessageChannel.request 'warning', "not implemented"
    return

    
module.exports = UserView

