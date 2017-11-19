gulp = require 'gulp'
plumber = require 'gulp-plumber'
slim = require 'gulp-slim'
sass = require 'gulp-sass'
connect = require 'gulp-connect'
sync = require 'browser-sync'

gulp.task 'build:slim', ->
	gulp.src('*.slim')
		.pipe(plumber())
		.pipe(slim({
			pretty: true,
		}))
		.pipe(gulp.dest(''))

gulp.task 'watch:slim', ->
	gulp.watch(['*.slim'], ['build:slim'])

gulp.task 'build:sass', ->
	gulp.src('*.scss', ['sass'])
		.pipe(plumber())
		.pipe(sass({
			outputStyle: 'expanded',
		}))
		.pipe(gulp.dest(''))

gulp.task 'watch:sass', ->
	gulp.watch(['*.scss'], ['build:sass'])

gulp.task 'connect', ->
	connect.server({
		root: './',
		livereload: true,
	})

gulp.task 'sync', ->
	sync({
		server: {
			baseDir: "./",
		}
	})

gulp.task 'sync:reload', ->
	sync.reload()

gulp.task 'watch:sync', ->
	gulp.watch('*.{html,css}', ['sync:reload'])

gulp.task 'build', ['build:slim', 'build:sass']

gulp.task 'watch', ['watch:slim', 'watch:sass', 'watch:sync']

gulp.task 'serve', ['connect', 'watch', 'sync']
