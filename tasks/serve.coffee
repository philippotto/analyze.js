module.exports = (gulp, $, options) ->

  gulp.task("serve", (done) ->
    gulp.src("dist")
      .pipe($.webserver(
        port : options.port
      ))
  )
