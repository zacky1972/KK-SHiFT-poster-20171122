gulp = require 'gulp'
del = require 'del'
sequence = require 'run-sequence'
plumber = require 'gulp-plumber'
slim = require 'gulp-slim'
sass = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'
connect = require 'gulp-connect'
sync = require 'browser-sync'
ghPages = require 'gulp-gh-pages'
rev = require 'gulp-rev'
revReplace = require 'gulp-rev-replace'

sources = {
	path: './sources',
}

build = {
	path: './dist',
	manifest: 'dist/rev-manifest.json',
}

gulp.task 'build:images', ->
	return gulp.src("#{sources.path}/assets/images/*")
		.pipe(gulp.dest("#{build.path}/assets/images/"))

gulp.task 'watch:images', ->
	gulp.watch("#{sources.path}/assets/images/*", ['build:images'])

gulp.task 'build:slim', ->
	return gulp.src("#{sources.path}/**/*.slim")
		.pipe(plumber())
		.pipe(slim({
			pretty: true,
		}))
		.pipe(gulp.dest("#{build.path}/"))

gulp.task 'watch:slim', ->
	gulp.watch("#{sources.path}/**/*.slim", ['build:slim'])

gulp.task 'build:html', ->
	return gulp.src("#{sources.path}/**/*.html")
		.pipe(plumber())
		.pipe(gulp.dest("#{build.path}/"))

gulp.task 'watch:html', ->
	gulp.watch("#{sources.path}/**/*.html", ['build:html'])

gulp.task 'rev-replace', ['rev'], ->
	manifest = gulp.src(build.manifest)
	return gulp.src("#{build.path}/**/*.+(html|css|js)")
		.pipe(plumber())
		.pipe(revReplace({manifest: manifest}))
		.pipe(gulp.dest("#{build.path}/"))

gulp.task 'build:sass', ->
	return gulp.src("#{sources.path}/assets/**/*.scss", ['sass'])
		.pipe(plumber())
		.pipe(sass({
			outputStyle: 'expanded',
			sourcemap: true,
		}))
		.pipe(sourcemaps.write())
		.pipe(gulp.dest("#{build.path}/assets/"))

gulp.task 'watch:sass', ->
	gulp.watch("#{sources.path}/assets/**/*.scss", ['build:sass'])

gulp.task 'build:css', ->
	return gulp.src("#{sources.path}/assets/**/*.css")
		.pipe(plumber())
		.pipe(gulp.dest("#{build.path}/assets/"))

gulp.task 'watch:css', ->
	gulp.watch("#{sources.path}/assets/**/*.css", ['build:css'])

gulp.task 'rev', ->
	return gulp.src("#{build.path}/assets/**/*.+(js|css|png|gif|jpg|jpeg|svg|woff|ico)")
		.pipe(rev())
		.pipe(gulp.dest("#{build.path}/assets/"))
		.pipe(rev.manifest())
		.pipe(gulp.dest("#{build.path}/assets/"))

gulp.task 'connect', ->
	return connect.server({
		root: "#{build.path}/",
		livereload: true,
	})

gulp.task 'sync', ->
	return sync({
		server: {
			baseDir: "#{build.path}/",
		}
	})

gulp.task 'sync:reload', ->
	return sync.reload()

gulp.task 'watch:sync', ->
	gulp.watch(["#{build.path}/**/*.html", "#{build.path}/**/*.css"], ['sync:reload', 'rev-replace'])

gulp.task 'gh-pages', ['build'], ->
	return gulp.src("#{build.path}/**/*")
		.pipe(ghPages())

gulp.task 'clean', (cb) ->
	return del(["#{build.path}/*"], cb)

gulp.task 'build:non-rev', ['build:sass', 'build:css', 'build:html', 'build:slim', 'build:images']

gulp.task 'build', ['build:non-rev'], ->
	return sequence 'rev', 'rev-replace'

gulp.task 'watch', ['watch:slim', 'watch:html', 'watch:sass', 'watch:css', 'watch:images', 'watch:sync']

gulp.task 'serve', ->
	sequence 'clean', 'build', 'connect', 'watch', 'sync'

gulp.task 'deploy', ->
	sequence 'clean', 'build', 'gh-pages'
