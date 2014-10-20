spawn = require('child_process').spawn
argv = require("minimist")(process.argv.slice(2))

module.exports = (gulp, $, options) ->

  getCmds = ->

    supervisorCmd = [
      "./node_modules/supervisor/lib/cli-wrapper.js"
      "--force-watch"
      "-w"
      "dist/scripts/backend/."
      "--no-restart-on"
      "error"
    ]

    proxyArgs = ["--", "dist/scripts/backend/instrumentation-proxy.js"]
    proxiedArgs = ["dist/scripts/backend/proxied-app.js"]

    if argv.proxiedPort
      proxyArgs.push("--proxiedPort", argv.proxiedPort)
    if argv.proxyPort
      proxyArgs.push("--proxyPort", argv.proxyPort)

    {supervisorCmd, proxyArgs, proxiedArgs}


  spawnAndLog = (name, args...) ->

    child = spawn(args...)
    child.stdout.on('data', (data) -> console.log(name, 'stdout:', data.toString()))
    child.stderr.on('data', (data) -> console.log(name, 'stderr:', data.toString()))
    child.on('exit', (code) -> console.log(name, 'child process exited with code', code))


  gulp.task("serve", (done) ->

    {supervisorCmd, proxyArgs, proxiedArgs} = getCmds()

    spawnAndLog("proxy-child  ", "node", supervisorCmd.concat(proxyArgs))

    if argv.proxiedPort
      # assume that a different webapp is already running
      return

    spawnAndLog("proxied-child", "node", supervisorCmd.concat(proxiedArgs))
  )
