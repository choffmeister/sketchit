path = require("path")
send = require("send")
mountFolder = (connect, dir) ->
  connect.static path.resolve(dir)

module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      dev:
        expand: true
        cwd: "src"
        src: ["**/*.coffee"]
        dest: "target/dev/src"
        ext: ".js"
        options:
          bare: true
      test:
        expand: true
        cwd: "test"
        src: ["**/*.coffee"]
        dest: "target/dev/test"
        ext: ".js"
        options:
          bare: true

    requirejs:
      prod:
        options:
          baseUrl: "target/dev/src"
          mainConfigFile: "target/dev/src/app.js"
          name: "app"
          out: "target/prod/src/app.js"
          optimize: "uglify"

    jade:
      dev:
        files: [
          expand: true
          cwd: "resources"
          src: "**/*.jade"
          dest: "target/dev"
          ext: ".html"
          rename: (dest, src) ->
            path.join dest, (if src is "index.html" then "_index.html" else src)
        ]
        options:
          pretty: true

      prod:
        files: [
          expand: true
          cwd: "resources"
          src: "**/*.jade"
          dest: "target/prod"
          ext: ".html"
        ]
        options:
          pretty: false

    less:
      dev:
        files: [
          src: "resources/styles/main.less"
          dest: "target/dev/styles/main.css"
        ]
        options:
          paths: ["resources/styles"]
          yuicompress: false

      prod:
        files: [
          src: "resources/styles/main.less"
          dest: "target/prod/styles/main.css"
        ]
        options:
          paths: ["resources/styles"]
          yuicompress: false

    copy:
      dev:
        files: [
          src: "resources/favicon.ico"
          dest: "target/dev/favicon.ico"
        ,
          expand: true
          cwd: "resources/images"
          src: "**/*.*"
          dest: "target/dev/images"
        ]

      prod:
        files: [
          src: "components/requirejs/require.js"
          dest: "target/prod/components/requirejs/require.js"
        ,
          expand: true
          cwd: "components/open-sans-fontface/font"
          src: "**/*.*"
          dest: "target/prod/components/open-sans-fontface/font"
        ,
          expand: true
          cwd: "components/icomoon"
          src: "**/*.*"
          dest: "target/prod/components/icomoon"
        ,
          src: "resources/favicon.ico"
          dest: "target/prod/favicon.ico"
        ,
          src: "resources/robots.txt"
          dest: "target/prod/robots.txt"
        ,
          src: "resources/.htaccess"
          dest: "target/prod/.htaccess"
        ,
          expand: true
          cwd: "resources/images"
          src: "**/*.*"
          dest: "target/prod/images"
        ,
          expand: true
          cwd: "components"
          src: "**/*.js"
          dest: "target/dev/components"
        ]

    connect:
      proxies: [
        context: "/api"
        host: "localhost"
        port: 8080
        https: false
        changeOrigin: false
      ]
      dev:
        options:
          port: 9000
          hostname: "0.0.0.0"
          middleware: (connect) ->
            [require("grunt-connect-proxy/lib/utils").proxyRequest
            , mountFolder(connect, "target/dev/")
            , mountFolder(connect, "")
            , (req, res, next) ->
              req.url = "/"
              next()
            , (req, res, next) ->
              error = (err) ->
                res.statusCode = err.status or 500
                res.end err.message

              notFound = ->
                res.statusCode = 404
                res.end "Not found"

              if req.originalUrl.match(/\.(html|css|js|png|jpg|gif)$/)
                notFound()
              else
                send(req, "_index.html").root("target/dev/").on("error", error).pipe res
            ]
      prod:
        options:
          port: 9001
          hostname: "0.0.0.0"
          keepalive: true
          middleware: (connect) ->
            [require("grunt-connect-proxy/lib/utils").proxyRequest
            , mountFolder(connect, "target/prod/"), (req, res, next) ->
              req.url = "/"
              next()
            , (req, res, next) ->
              error = (err) ->
                res.statusCode = err.status or 500
                res.end err.message

              notFound = ->
                res.statusCode = 404
                res.end "Not found"

              if req.originalUrl.match(/\.(html|css|js|png|jpg|gif)$/)
                notFound()
              else
                send(req, "index.html").root("target/prod/").on("error", error).pipe res
            ]

    open:
      dev:
        url: "http://localhost:<%= connect.dev.options.port %>"
      prod:
        url: "http://localhost:<%= connect.prod.options.port %>"

    watch:
      options:
        livereload: true

      coffeedev:
        files: ["src/**/*.coffee"]
        tasks: ["coffee:dev"]

      jade:
        files: ["resources/**/*.jade"]
        tasks: ["jade:dev"]

      less:
        files: ["resources/styles/**/*.less"]
        tasks: ["less:dev"]

      images:
        files: ["resources/images/**/*.*"]
        tasks: ["copy:dev"]

    karma:
      options:
        singleRun: true
        autoWatch: false
        browsers: ["Chrome"]
      unit:
        configFile: "karma-unit.conf.js"
      e2e:
        configFile: "karma-e2e.conf.js"

    clean:
      dev: ["target/dev/"]
      prod: ["target/prod/"]

  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks
  grunt.registerTask "dev-build", ["clean:dev", "coffee:dev", "jade:dev", "less:dev", "copy:dev"]
  grunt.registerTask "prod-build", ["dev-build", "clean:prod", "copy:prod", "requirejs:prod", "jade:prod", "less:prod"]
  grunt.registerTask "test-build", ["dev-build", "coffee:test"]
  grunt.registerTask "dev-server", ["configureProxies", "open:dev", "connect:dev"]
  grunt.registerTask "prod-server", ["configureProxies", "open:prod", "connect:prod"]
  grunt.registerTask "test", ["test-build", "dev-server", "karma:unit"]
  grunt.registerTask "default", ["dev-build", "dev-server", "watch"]
