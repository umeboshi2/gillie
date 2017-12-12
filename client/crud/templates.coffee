Backbone = require 'backbone'
tc = require 'teacup'
marked = require 'marked'

{ form_group_input_div 
  make_field_input } = require 'tbirds/templates/forms'
{ modal_close_button } = require 'tbirds/templates/buttons'

capitalize = require 'tbirds/util/capitalize'

MainChannel = Backbone.Radio.channel 'global'

########################################
# Templates
########################################

itemTemplateFactory = (opts) ->
  tc.renderable (model) ->
    itemBtn = ".btn.btn-default.btn-sm"
    tc.div '.col-sm-8', ->
      href = "##{opts.routeName}/#{opts.name}s/view/#{model.id}"
      tc.a href: href, model[opts.entryField]
    tc.div '.col-sm-4', ->
      tc.div '.btn-group.pull-right', ->
        tc.button ".edit-item.#{itemBtn}.btn-info.fa.fa-edit", 'edit'
        tc.button ".delete-item.#{itemBtn}.btn-danger.fa.fa-close", 'delete'

listTemplateFactory = (opts) ->
  tc.renderable (model) ->
    tc.div '.listview-header', ->
      tc.text capitalize opts.name
    tc.button "#add-#{opts.name}.btn.btn-default.fa.fa-plus", ->
      "Add #{capitalize opts.name}"
    tc.hr()
    tc.ul "##{opts.name}-container.list-group"


formInputsFactory = (opts) ->
  tc.renderable (model) ->
    tc.div '.listview-header', model[opts.entryField]
    for field in opts.fieldList
      make_field_input(field)(model)
    tc.input '.btn.btn-default', type:'submit', value:'Submit'
    tc.div '.spinner.fa.fa-spinner.fa-spin'
    

confirmDeleteTemplate = tc.renderable (model) ->
  tc.div '.modal-dialog', ->
    tc.div '.modal-content', ->
      tc.h3 "Do you really want to delete #{model.name}?"
      tc.div '.modal-body', ->
        tc.div '#selected-children'
      tc.div '.modal-footer', ->
        tc.ul '.list-inline', ->
          btnclass = 'btn.btn-default.btn-sm'
          tc.li "#confirm-delete-button", ->
            modal_close_button 'OK', 'check'
          tc.li "#cancel-delete-button", ->
            modal_close_button 'Cancel'
    


MainChannel.reply 'crud:template:item', (options) ->
  itemTemplateFactory options
MainChannel.reply 'crud:template:list', (options) ->
  listTemplateFactory options
MainChannel.reply 'crud:template:form', (options) ->
  formInputsFactory options
    
  

module.exports =
  confirmDeleteTemplate: confirmDeleteTemplate
