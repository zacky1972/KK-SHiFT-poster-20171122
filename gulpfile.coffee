gulp = require 'gulp'
del = require 'del'
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
	path: 'sources/',
}

build = {
	path: 'dist/',
	manifest: 'dist/rev-manifest.json',
}

gulp.task 'build:slim', ->
	gulp.src(sources.path + '**/*.slim')
		.pipe(plumber())
		.pipe(slim({
			pretty: true,
		}))
		.pipe(gulp.dest(build.path))

gulp.task 'watch:slim', ->
	gulp.watch([sources.path + '**/*.slim'], ['build:slim', 'rev-replace:html'])

gulp.task 'build:html', ->
	gulp.src(sources.path + '**/*.html')
		.pipe(plumber())
		.pipe(gulp.dest(build.path))

gulp.task 'rev-replace:html', ['build:html', 'build:slim', 'build:sass'], ->
	manifest = gulp.src(build.manifest)
	gulp.src(build.path + '**/*.html')
		.pipe(plumber())
		.pipe(revReplace({manifest: manifest}))
		.pipe(gulp.dest(build.path))

gulp.task 'build:sass', ->
	gulp.src(sources.path + '**/*.scss', ['sass'])
		.pipe(plumber())
		.pipe(sass({
			outputStyle: 'expanded',
			sourcemap: true,
		}))
		.pipe(rev())
		.pipe(sourcemaps.write())
		.pipe(gulp.dest(build.path))
		.pipe(rev.manifest())
		.pipe(gulp.dest(build.path))

gulp.task 'watch:sass', ->
	gulp.watch([sources.path + '**/*.scss'], ['build:sass', 'rev-replace:html'])

gulp.task 'connect', ->
	connect.server({
		root: build.path,
		livereload: true,
	})

gulp.task 'sync', ->
	sync({
		server: {
			baseDir: build.path,
		}
	})

gulp.task 'sync:reload', ->
	sync.reload()

gulp.task 'watch:sync', ->
	gulp.watch(build.path + '**/*.{html,css}', ['sync:reload'])

gulp.task 'gh-pages', ['build'], ->
	gulp.src(build.path + '**/*')
		.pipe(ghPages())

gulp.task 'clean', (cb) ->
	del(["#{build.path}/*"], cb)

gulp.task 'build', ['clean', 'build:sass', 'build:slim']

gulp.task 'watch', ['watch:slim', 'watch:sass', 'watch:sync']

gulp.task 'serve', ['connect', 'watch', 'sync']

gulp.task 'deploy', ['build', 'gh-pages']
