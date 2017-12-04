$ = require 'jquery'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
Masonry = require 'masonry-layout'
tc = require 'teacup'

navigate_to_url = require 'tbirds/util/navigate-to-url'
{ make_field_input
  make_field_select } = require 'tbirds/templates/forms'
{ modal_close_button } = require 'tbirds/templates/buttons'

HasImageModal = require '../has-image-modal'

MainChannel = Backbone.Radio.channel 'global'
MessageChannel = Backbone.Radio.channel 'messages'
AppChannel = Backbone.Radio.channel 'sofi'

########################################
class ComicImageView extends Backbone.Marionette.View
  template: tc.renderable (model) ->
    img = AppChannel.request 'fix-image-url', model.image_src
    tc.img '.thumb.media-object', src:img
  ui:
    image: 'img'
  triggers:
    'click @ui.image': 'show:image:modal'
  behaviors: [HasImageModal]
  onDomRefresh: ->
    @trigger 'show:image'

module.exports = ComicImageView




