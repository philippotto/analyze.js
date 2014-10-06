exec = require("child_process").exec
argv = require("minimist")(process.argv.slice(2))

module.exports = (gulp, $, options) ->

  gulp.task("serve", (done) ->


    cmd = "dist/scripts/backend/instrumentation-proxy.js"
    if argv.proxiedPort
      cmd + " --proxiedPort " + argv.proxiedPort
    if argv.proxyPort
      cmd + " --proxyPort " + argv.proxyPort

    exec("supervisor --force-watch -w dist/scripts/backend/. " + cmd, (err, stdout, stderr) ->
      console.log("stdout",  stdout)
      console.log("stderr",  stderr)
      done(err)
    )

    if argv.proxiedPort
      # assume that a different webapp is already running
      return

    exec("supervisor --force-watch -w dist/scripts/backend/. dist/scripts/backend/proxied-app.js", (err, stdout, stderr) ->
      console.log("stdout",  stdout)
      console.log("stderr",  stderr)
      done(err)
    )
  )
