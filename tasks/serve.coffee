exec = require("child_process").exec

module.exports = (gulp, $, options) ->

  gulp.task("serve", (done) ->

    exec("supervisor --force-watch -w dist/scripts/backend/. dist/scripts/backend/instrumentation-proxy.js", (err, stdout, stderr) ->
      console.log("stdout",  stdout)
      console.log("stderr",  stderr)
      done(err)
    )

    exec("supervisor --force-watch -w dist/scripts/backend/. dist/scripts/backend/proxied-app.js", (err, stdout, stderr) ->
      console.log("stdout",  stdout)
      console.log("stderr",  stderr)
      done(err)
    )

  )
