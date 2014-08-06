module.exports = (gulp, $) ->

  gulp.task("clean", (done) ->
    $.rimraf(options.dest.dir, done)
  )
