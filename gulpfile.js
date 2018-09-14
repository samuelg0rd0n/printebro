const gulp = require('gulp');
const plumber = require('gulp-plumber');
const usage = require('gulp-help-doc');
const concat = require('gulp-concat');
const sass = require('gulp-sass');
const path = require('path');
const del = require('del');
const sourcemaps = require('gulp-sourcemaps');
const composer = require('gulp-composer');
const cleanCSS = require('gulp-clean-css');
const uglify = require('gulp-uglify');
const babel = require('gulp-babel');
const filter = require('gulp-filter');
const exec = require('child_process').exec;

const jsFiles = [

	// vendor
	'node_modules/bootstrap/dist/js/bootstrap.js',
	'node_modules/lightgallery.js/dist/js/lightgallery.js',

	// app
	'www/src/js/libs/**/*.js',
	'www/src/js/**/*.js'
];

const appJsFilesFilter = filter(['**/www/src/js/**/*'], {restore: true});

const babelConfig = {
	presets: [
		['env', {
			targets: {
				browsers: [ '> 0.25%', 'not dead', 'last 2 versions']
			}
		}]
	]
};

const errorHandler = function(err) {
	console.error(`An error occurred in ${err.fileName}`);
	console.error(`${err.name}: ${err.message}`);
};

/**
 * Prints list of all available gulp commands.
 */
gulp.task('default', () => {
	return usage(gulp);
});

/**
 * Inits the project for development (i.e. after being cloned from GIT).
 *
 * @task {init}
 * @group {Development}
 */
gulp.task('init', ['js', 'css', 'assets']);

/**
 * Transpiles and concatenates all JS files into a single file.
 *
 * @task {js}
 * @group {Development}
 */
gulp.task('js', () => {
	return gulp.src(jsFiles)
		.pipe(plumber({ errorHandler }))
		.pipe(sourcemaps.init())
		.pipe(appJsFilesFilter)
		.pipe(babel(babelConfig))
		.pipe(appJsFilesFilter.restore)
		.pipe(concat('app.js'))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest('./www/dist/js/'));
});

/**
 * Transforms source SASS/SCSS files into a single CSS file.
 *
 * @task {css}
 * @group {Development}
 */
gulp.task('css', () => {
	return gulp.start(['build:css']);
});

/**
 * Watches for changes in SASS/SCSS and JS files.
 *
 * @task {watch}
 * @group {Development}
 */
gulp.task('watch', ['js', 'css'], () => {
	let cssWatcher = gulp.watch('www/src/scss/**/*.scss', ['css']);
	cssWatcher.on('change', (event) => {
		console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
	});
	let jsWatcher = gulp.watch('www/src/js/**/*.js', ['js']);
	jsWatcher.on('change', (event) => {
		console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
	});
});


/**
 * Builds all files necessary for a deployment and moves assets into a dist directory.
 *
 * @task {build}
 * @group {Deployment}
 */
gulp.task('build', ['clean'], () => {
	gulp.start(['build:js', 'build:css', 'assets']);
});


/**
 * Transpiles, uglifies and concatenates all JS files into a single file.
 *
 * @task {build:js}
 * @group {Deployment}
 */
gulp.task('build:js', () => {
	return gulp.src(jsFiles)
		.pipe(sourcemaps.init())
		.pipe(appJsFilesFilter)
		.pipe(babel(babelConfig))
		.pipe(appJsFilesFilter.restore)
		.pipe(uglify())
		.pipe(concat('app.js'))
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest('./www/dist/js/'));
});

/**
 * Transforms source SASS/SCSS files into a single CSS file and minifies it.
 *
 * @task {build:css}
 * @group {Deployment}
 */
gulp.task('build:css', () => {
	return gulp.src([
		'./www/src/scss/app.scss'
	])
		.pipe(sourcemaps.init())
		.pipe(sass().on('error', sass.logError))
		.pipe(cleanCSS({
			rebase: false,
		})) // minify
		.pipe(sourcemaps.write('.'))
		.pipe(gulp.dest('./www/dist/css/'));
});

/**
 * Cleans temp and dist directories.
 *
 * @task {clean}
 * @group {Clean}
 */
gulp.task('clean', ['clean:temp', 'clean:dist']);

/**
 * Cleans temp directory.
 *
 * @task {clean:temp}
 * @group {Clean}
 */
gulp.task('clean:temp', () => {
	return del([
		'./temp/**/*',
		'!./temp/.gitignore'
	]);
});

/**
 * Cleans dist directory.
 *
 * @task {clean:dist}
 * @group {Clean}
 */
gulp.task('clean:dist', () => {
	return del([
		'./www/dist/**/*',
		'!./www/dist/.gitignore'
	]);
});

/**
 * Moves all assets into a dist directory.
 *
 * @task {assets}
 * @group {Misc}
 */
gulp.task('assets', () => {
	gulp.src([
		'./node_modules/jquery/dist/jquery.js'
	]).pipe(gulp.dest('./www/dist/js'));

	gulp.src([
		'./node_modules/lightgallery.js/dist/img/loading.gif'
	]).pipe(gulp.dest('./www/dist/images'));

	return gulp.src([
		'./node_modules/@fortawesome/fontawesome-free/webfonts/*',
		'./node_modules/lightgallery.js/dist/fonts/*'
	]).pipe(gulp.dest('./www/dist/fonts'))
});

/**
 * Runs `composer install`
 *
 * @task {composer}
 * @group {Misc}
 */
gulp.task('composer', () => {
	composer('install');
});