'use strict'

# Options which ought to be set via environment
NODE_ENV = 'dev'
MINIFY = no # Uglify (minify) all scripts
TODOS = yes # print TODOs found in code
afterEveryRun = [ 'spec' ] # tasks to run after EVERY set of tasks
ASSETURL = '/' # base URL to be passed to Jade and Less
DEVPORT = 8080 # The port gulp-connect will listen on

# A friendly task list!
# Watch will automatically search for all configurations with a 'tasks' list that can be run
# set "path" and "tasks" minimally - this would imply there is no output for the gulp task
# set an "output" for tasks that require one - like browserify, jade, less, etc.
# set a "watch" to have the event fire whenever the "watch" value changes :)
tasks = {
  gulpfile: [
    {
      path: './gulpfile.coffee'
      tasks: [ 'lint' ]
    }
  ]
  fonts: [
    {
      path: './client/fonts/**/*'
      watch: './client/fonts/*'
      output: 'public/fonts'
      tasks: [ 'assets' ]
    }
  ]
  images: [
    {
      path: './client/assets/**/*'
      watch: './client/assets/*'
      output: 'public/assets'
      tasks: [ 'assets' ]
    }
  ]
  browserify: [
    {
      path: './client/index.coffee'
      watch: 'client/**/*.coffee'
      output: 'public/bundle.js'
      tasks: [ 'browserify', 'lint' ]
    }
  ]
  spec: [
    {
      path: './spec/index.js'
      watch: 'spec/*.coffee'
      tasks: [ 'spec' ]
    }
  ],
  server: [
    {
      path: './server/server.coffee'
      watch: 'server/*.coffee'
      tasks: [ 'lint' ]
    }
  ]
  jade: [
    {
      path: './client/index.jade'
      watch: 'client/**/*.jade'
      output: 'public/index.html'
      tasks: [ 'jade' ]
    }
  ]
  less: [
    {
      path: './client/style/index.less'
      watch: 'client/style/*.less'
      output: 'public/style.css'
      tasks: [ 'less' ]
    }
  ]
  vendor: [
    {
      path: './client/vendor/*.js'
      watch: 'client/vendor/*.js'
      output: 'public/vendor.js'
      tasks: [ 'vendor' ]
    }
  ]
}

path      = require 'path'
fs        = require 'fs'
_         = require 'underscore'
gulp      = require 'gulp'
gutil     = require 'gutil'
concat    = require 'gulp-concat'
lint      = require 'gulp-coffeelint'
mocha     = require 'gulp-mocha'
shell     = require 'gulp-shell'
jade      = require 'gulp-jade'
less      = require 'gulp-less'
server    = require 'gulp-nodemon'
streamify = require 'gulp-streamify'
connect   = require 'gulp-connect'
watch     = require 'gulp-watch'
rename    = require 'gulp-rename'
browser   = require 'browserify'
source    = require 'vinyl-source-stream'
seq       = require 'run-sequence'

WATCHING = no
if TODOS? then afterEveryRun.unshift 'todos'

gulp.task 'default', ->
  run = []
  for type, file of tasks
    for conf in file
      if conf.path? and conf.output? and conf.tasks?
        for task in conf.tasks
          run.push task
  for task in afterEveryRun
    run.push task
  #console.log 'default task list', _.uniq run
  seq _.uniq run

gulp.task 'watch', ->
  seq 'server', 'connect'
  WATCHING = yes
  run = []
  for type, file of tasks
    for conf in file
      if conf.path? and conf.output? and conf.tasks? and conf.watch?
        run.push conf
  for conf in run
    doWatch conf
  setTimeout ->
    seq 'todos', 'spec'
  , 100

# Start gulp-watch with a task configuration
doWatch = (conf) ->
  gulp
    .src(conf.watch)
    .pipe watch conf.watch, (e, done) ->
      for gulpTask in conf.tasks
        gulp.start gulpTask
        done() if done?

# Gather tasks from the tasks object into gulpable configurations
gatherTasks = (task, cb) ->
  applicablePaths = []
  for type, details of tasks
    (applicablePaths.push details for applicable in details when applicable.tasks.indexOf(task) > -1)
  for details in applicablePaths
    for detail in details
      #console.log task.toUpperCase()+':', detail.path
      cb(detail)

gulp.task 'connect', ->
  connect.server {
    root: 'public'
    port: DEVPORT
    livereload: yes
  }

gulp.task 'server', ->
  server {
    script: './server/index.js'
    # This doesn't work in win32. Not sure why yet.
    # turn on verbose mode and notice "0 files watched"
    watch: 'server'
    ext: 'coffee'
    env: { 'NODE_ENV': NODE_ENV }
    ignore: ['node_modules']
    verbose: no
    dump: no
  }
  .on 'restart', ->
    seq 'lint', 'spec', 'todos'

gulp.task 'browserify', ->
  for entry in tasks.browserify
    stream = browser({
      entries: [entry.path]
      extensions: ['.coffee']
    }).transform 'coffeeify'
      .bundle()
      .pipe source 'client.js'
    if MINIFY then stream.pipe streamify uglify()
    stream.pipe gulp.dest 'public'
      .on 'error', gutil.log
    if WATCHING then stream.pipe connect.reload()

gulp.task 'lint', ->
  gatherTasks 'lint', (details) ->
    stream = gulp.src details.path
      .pipe lint()
      .pipe lint.reporter()
      .on 'error', (err) ->
        console.log 'lint err', err.toString()
    if WATCHING then stream.pipe connect.reload()

gulp.task 'jade', ->
  gatherTasks 'jade', (details) ->
    stream = gulp.src details.path
      .pipe jade {
        locals: {
          assetURL: ASSETURL
        }
      }
      .pipe gulp.dest 'public'
      .on 'error', (err) ->
        console.log err.toString()
        @emit 'end'
    if WATCHING then stream.pipe connect.reload()

gulp.task 'less', ->
  gatherTasks 'less', (details) ->
    stream = gulp.src details.path
      .pipe less {
        compress: MINIFY
        rootpath: ASSETURL
      }
      .pipe rename 'style.css'
      .pipe gulp.dest 'public'
      .on 'error', gutil.log
    if WATCHING then stream.pipe connect.reload()

gulp.task 'vendor', ->
  gatherTasks 'vendor', (details) ->
    stream = gulp.src details.path
      .pipe concat 'vendor.js'
      .pipe gulp.dest 'public'
    if WATCHING then stream.pipe connect.reload()

gulp.task 'todos', ->
  gatherTasks 'todos', (details) ->
    stream = gulp.src details.path, { read: no }
      .pipe shell ['grep -Hn "TODO:" <%= file.path %>'], { ignoreErrors: yes }
      .on 'error', gutil.log
    if WATCHING then stream.pipe connect.reload()

gulp.task 'spec', ->
  gatherTasks 'spec', (details) ->
    stream = gulp.src details.path
      .pipe mocha { reporter: 'spec' }
      .on 'error', (err) ->
        console.log err.toString()
        @emit 'end'
    if WATCHING then stream.pipe connect.reload()

gulp.task 'assets', ->
  gatherTasks 'assets', (details) ->
    stream = gulp.src details.path
      .pipe gulp.dest details.output
      .on 'error', gutil.log
    if WATCHING then stream.pipe connect.reload()
