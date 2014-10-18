http = require("http")
connect = require("connect")
httpProxy = require("http-proxy")
transformerProxy = require("transformer-proxy")
serveStatic = require("serve-static")
finalhandler = require("finalhandler")
errorhandler = require("errorhandler")
Instrumenter = require("../instrumentation/Instrumenter.js")
argv = require("minimist")(process.argv.slice(2))

transformerFunction = (data, req) ->
  instrumenter.instrument(data.toString(), req.url)


isNativeCode = (req) ->
  req.url.indexOf("analyzejs/") > -1


isJavaScript = (req) ->
  /\.js([^\w]|$)/.test req.url


proxiedPort = argv.proxiedPort or 3000
proxyPort = argv.proxyPort or 8013

app = connect()

proxy = httpProxy.createProxyServer(target: "http://localhost:" + proxiedPort)
transformer = transformerProxy(transformerFunction)
serve = serveStatic("dist")

instrumenter = new Instrumenter()


app.use errorhandler()

app.use (req, res, next) ->
  if not isNativeCode(req) and isJavaScript(req)
    transformer req, res, next
  else
    next()

app.use (req, res) ->
  if isNativeCode(req)
    req.url = req.url.replace("analyzejs/", "")
    serve req, res, finalhandler(req, res)
  else
    proxy.web req, res

http.createServer(app).listen proxyPort

console.log "The proxied server listens on", proxiedPort
console.log "The proxy server listens on", proxyPort


process.on "uncaughtException", (error) ->
  console.error("stack:", error.stack)
  console.error("error:", error)
