module.exports = (gulp, $) ->

  gulp.task("bump:minor", (done) ->
    gulp.src(["package.json", "bower.json"])
      .pipe($.bump( type: "minor" ))
      .pipe(gulp.dest("."))
      .pipe($.logger())
  )

  gulp.task("bump:patch", (done) ->
    gulp.src(["package.json", "bower.json"])
      .pipe($.bump( type: "patch" ))
      .pipe(gulp.dest("."))
      .pipe($.logger())
  )

  gulp.task("bump:prerelease", (done) ->
    gulp.src(["package.json", "bower.json"])
      .pipe($.bump( type: "prerelease" ))
      .pipe(gulp.dest("."))
      .pipe($.logger())
  )
