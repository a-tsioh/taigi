require! <[express gulp gulp-concat tiny-lr gulp-livereload]>

livereload-server = tiny-lr!
livereload-port = 35729
livereload = -> gulp-livereload livereload-server

require! <[gulp-livescript gulp-browserify liveify gulp-uglify]>

gulp.task 'js:app' ->
  gulp.src 'app/js/app.ls'
    .pipe gulp-livescript bare: true
    .pipe gulp-browserify do
      transform: <[liveify]>
      extensions: <[.ls]>
    #.pipe gulp-uglify!
    .pipe gulp.dest '_public/js'
    .pipe livereload!

require! <[gulp-bower main-bower-files gulp-filter]>

gulp.task 'bower' ->
  gulp-bower!

gulp.task 'js:vendor' <[bower]> ->
  gulp.src main-bower-files!
    .pipe gulp-filter (.path is /\.js$/)
    .pipe gulp-concat 'vendor.js'
    .pipe gulp.dest '_public/js'
    .pipe livereload!

require! <[gulp-stylus]>

gulp.task 'css:app' ->
  gulp.src 'app/styles/*.styl'
    .pipe gulp-stylus!
    .pipe gulp-concat 'app.css'
    .pipe gulp.dest '_public/css'
    .pipe livereload!

gulp.task 'css:vendor' <[bower]> ->
  gulp.src main-bower-files!
    .pipe gulp-filter (.path is /\.css$/)
    .pipe gulp-concat 'vendor.css'
    .pipe gulp.dest '_public/css'
    .pipe livereload!

gulp.task 'css' <[css:app css:vendor]> ->

gulp.task 'assets:semantic-ui' <[bower]> ->
  gulp.src 'bower_components/semantic-ui/dist/themes/**/*'
    .pipe gulp.dest '_public/css/themes'

gulp.task 'assets' <[assets:semantic-ui]> ->

gulp.task 'template' ->
  gulp.src 'app/**/*.html'
    .pipe gulp.dest '_public'
    .pipe livereload!

gulp.task 'data' ->
  gulp.src 'app/**/*.csv'
    .pipe gulp.dest '_public'
    .pipe livereload!

gulp.task 'build' <[bower js:vendor js:app css assets template data]> ->

gulp.task 'watch' ->
  livereload-server.listen livereload-port, ->
    gulp.watch ['app/**/*.ls'] <[js:app]>
    gulp.watch ['app/**/*.styl'] <[css:app]>
    gulp.watch ['app/**/*.html'] <[template]>
    gulp.watch ['app/**/*.csv'] <[data]>

gulp.task 'dev' <[build watch]> ->
  require! <[express]>
  port = 3000
  app = express!
    .use require('connect-livereload')!
    .use '/' express.static '_public'
  console.log "Running on http://localhost:#port"
  app.listen port

gulp.task 'default' <[dev]> ->
