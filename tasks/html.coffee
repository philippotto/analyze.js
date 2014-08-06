module.exports = (gulp, $, options) ->

  gulp.task("html", (done) ->
    gulp.src(options.src.html)
      .pipe($.changed(options.dest.dir))
    	.pipe(gulp.dest(options.dest.dir))
      .pipe($.logger())
  )
