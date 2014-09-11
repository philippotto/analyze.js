http = require('http')
connect = require('connect')
serveStatic = require("serve-static")

proxyPort = 3000

app = connect()
app.use(serveStatic("dist/scripts/proxied-app/"))

http.createServer(app).listen proxyPort
