$= require 'jquery'
_ = require 'underscore'
Backbone = require 'backbone'
require 'backbone.routefilter'
Marionette = require 'backbone.marionette'


if __DEV__
  if window.__agent
    window.__agent.start Backbone, Marionette
  
module.exports = {}



