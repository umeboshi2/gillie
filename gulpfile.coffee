# inspired by https://github.com/KyleAMathews/coffee-react-quickstart
fs = require 'fs'
path = require 'path'

gulp = require 'gulp'
gutil = require 'gulp-util'
size = require 'gulp-size'
nodemon = require 'gulp-nodemon'
sourcemaps = require 'gulp-sourcemaps'
minimist = require 'minimist'
shell = require 'shelljs'

coffee = require 'gulp-coffee'
#runSequence = require 'run-sequence'
#concat = require 'gulp-concat'
#uglify = require 'gulp-uglify'

webpack = require 'webpack'

#gulp.task 'serve', ['coffee', 'ghost-config'], (callback) ->
gulp.task 'serve', (callback) ->
  process.env.__DEV_MIDDLEWARE__ = 'true'
  #gulp.watch './ghost-config.coffee', ->
  #  gulp.start 'ghost-config'
  nodemon
    script: 'server.js'
    ext: 'js coffee'
    watch: [
      'config.coffee'
      'src'
      'webpack-config'
      'webpack.config.coffee'
      ]
      
gulp.task 'serve:api', (callback) ->
  process.env.__DEV_MIDDLEWARE__ = 'false'
  # add trailing slash to match openshift
  process.env.OPENSHIFT_DATA_DIR = "#{__dirname}/"
  #gulp.watch './ghost-config.coffee', ->
  #  gulp.start 'ghost-config'
  nodemon
    #nodeArgs: '--inspect'
    script: 'server.js'
    ext: 'js coffee'
    watch: [
      'config.coffee'
      'src'
      'webpack-config'
      'webpack.config.coffee'
      ]
  
gulp.task 'serve:prod', (callback) ->
  process.env.PRODUCTION_BUILD = 'true'
  process.env.NODE_ENV = 'production'
  process.env.__DEV_MIDDLEWARE__ = 'false'
  gulp.watch './ghost-config.coffee', ->
    gulp.start 'ghost-config'
  nodemon
    script: 'server.js'
    ext: 'js coffee'
    watch: [
      'config.coffee'
      'src/'
      'webpack-config/'
      'webpack.config.coffee'
      ]
  
gulp.task 'webpack:build-prod', (callback) ->
  statopts =
    colors: true
    chunks: true
    modules: false
    #reasons: true
    maxModules: 9999
  # run webpack
  process.env.PRODUCTION_BUILD = 'true'
  process.env.NODE_ENV = 'production'
  ProdConfig = require './webpack.config'
  prodCompiler = webpack ProdConfig
  prodCompiler.run (err, stats) ->
    throw new gutil.PluginError('webpack:build-prod', err) if err
    gutil.log "[webpack:build-prod]", stats.toString statopts
    callback()
    return
  return

gulp.task 'default', ->
  gulp.start 'serve'
  
gulp.task 'production', ->
  gulp.start 'webpack:build-prod'
