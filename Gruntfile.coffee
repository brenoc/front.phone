module.exports = (grunt) ->
	pkg = grunt.file.readJSON('package.json')

	replacements =
		'VTEX_IO_HOST': 'io.vtex.com.br'
		'VERSION': pkg.version

	# Project configuration.
	grunt.initConfig
		relativePath: ''

		# Tasks
		clean: 
			main: ['build', 'build-raw', 'tmp-deploy']

		copy:
			main:
				files: [
					expand: true
					cwd: 'src/'
					src: ['**', '!coffee/**']
					dest: 'build-raw/<%= relativePath %>'
				,
					src: ['src/index.html']
					dest: 'build-raw/<%= relativePath %>/index.debug.html'
				]
			build:
				expand: true
				cwd: 'build-raw/'
				src: '**/*.*'
				dest: 'build/'
			dist:
				expand: false
				src: ['build/js/vtex-phone.js']
				dest: 'dist/vtex-phone.js'

		coffee:
			main:
				files: [
					expand: true
					cwd: 'src/coffee'
					src: ['**/*.coffee']
					dest: 'build-raw/<%= relativePath %>/js/'
					ext: '.js'
				]

		useminPrepare:
			html: 'build-raw/<%= relativePath %>/index.html'

		usemin:
			html: 'build-raw/<%= relativePath %>/index.html'

		###
		uglify:
			dist:
				files:
					'dist/front-phone.min.js': ['dist/people.js']
		###

		karma:
			options:
				configFile: 'karma.conf.coffee'
			unit:
				background: true
			single:
				singleRun: true

		connect:
			main:
				options:
					port: 9001
					base: 'build/'

		remote: main: {}

		watch:
			main:
				options:
					livereload: true
				files: ['src/**/*.html', 'src/**/*.coffee', 'spec/**/*.coffee', 'src/**/*.js']
				tasks: ['clean', 'concurrent:transform', 'copy:build', 'karma:unit:run']

		concurrent:
			transform: ['copy:main', 'coffee']

		vtex_deploy:
			main:
				options:
					buildDirectory: 'build'
					indexPath: 'build/index.html'
					whoamiPath: 'whoami'
					includeHostname:
						hostname: 'io.vtex.com.br'
						files: ["build/index.html", "build/index.debug.html"]
			walmart:
				options:
					buildDirectory: 'build-raw'
					bucket: 'vtex-io-walmart'
					requireEnvironmentType: 'stable'
					includeHostname:
						hostname: 'VTEX_IO_HOST'
						files: ["build-raw/index.html", "build-raw/index.debug.html"]

	grunt.loadNpmTasks name for name of pkg.dependencies when name[0..5] is 'grunt-'

	grunt.registerTask 'default', ['clean', 'concurrent:transform', 'copy:build', 'server', 'karma:unit', 'watch:main']
	grunt.registerTask 'dist', ['clean', 'concurrent:transform', 'useminPrepare', 'concat', 'usemin', 'copy:build', 'copy:dist'] # Dist - minifies files
	grunt.registerTask 'test', ['karma:single']
	grunt.registerTask 'server', ['connect', 'remote']