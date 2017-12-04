Backbone = require 'backbone'
qs = require 'qs'

HubChannel = Backbone.Radio.channel 'hubby'

#apiroot = 'https://infidel-frobozz.rhcloud.com/api/dev/lgr'
apiroot = "/rest/v0/main"

meetingRoot = "#{apiroot}/meeting"
class SimpleMeetingModel extends Backbone.Model
  urlRoot: meetingRoot

class MainMeetingModel extends Backbone.Model
  urlRoot: meetingRoot
    
class MeetingCollection extends Backbone.Collection
  model: SimpleMeetingModel
  url: meetingRoot
  parse: (response) ->
    super response.data
    

itemRoot = "#{apiroot}/item"
class SimpleItemModel extends Backbone.Model
  urlRoot: itemRoot
    
  

class ItemCollection extends Backbone.Collection
  model: SimpleItemModel
  url: () ->
    "#{apiroot}/item/search?#{qs.stringify @searchParams}"
    
  
main_meeting_list = new MeetingCollection
HubChannel.reply 'meetinglist', ->
  main_meeting_list

module.exports =
  apiroot: apiroot
  MeetingCollection: MeetingCollection
  MainMeetingModel: MainMeetingModel
  ItemCollection: ItemCollection
  
