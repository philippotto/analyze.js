// require('coffee-script/register');
var gulp = require('gulp');
var gutil = require('gulp-util');

var coffee = require('gulp-coffee');

var paths = {
  scripts: ['./src/*.coffee'],
  images: 'client/img/**/*'
};

gulp.task('coffee', function() {
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true}).on('error', function() {
    	gutil.beep();
    	gutil.log(arguments);
    }))
    .pipe(gulp.dest('./public/'))
});


gulp.task('watch', function() {
	gulp.watch(paths.scripts, ["coffee"]);
})