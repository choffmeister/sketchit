path = require("path")

module.exports = (grunt) ->
  grunt.initConfig
    express:
      dev:
        options:
          port: 3000
          hostname: "localhost"
          server: "src/server/server.coffee"
          bases: [
            "public/**/*.html"
            "public/**/*.css"
            "src/**/*.js"
          ]
          livereload: true

    coffee:
      dev:
        expand: true
        cwd: "src"
        src: "**/*.coffee"
        dest: "src"
        ext: ".js"
      options:
        bare: true

    jade:
      dev:
        expand: true
        cwd: "public"
        src: "**/*.jade"
        dest: "public"
        ext: ".html"
      options:
        pretty: true

    less:
      dev:
        src: "public/styles/main.less"
        dest: "public/styles/main.css"
      options:
        paths: ["public"]
        yuicompress: false

    watch:
      options:
        livereload: true

      coffee:
        files: ["src/**/*.coffee"]
        tasks: ["coffee:dev"]

      jade:
        files: ["public/**/*.jade"]
        tasks: ["jade:dev"]

      less:
        files: ["public/**/*.less"]
        tasks: ["less:dev"]

    open:
      dev:
        url: "http://localhost:<%= express.dev.options.port %>"

  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  grunt.registerTask "build:dev", ["coffee:dev", "jade:dev", "less:dev"]
  grunt.registerTask "default", ["build:dev", "express:dev", "open:dev", "watch"]
