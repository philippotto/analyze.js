var http = require('http'),
    connect = require('connect'),
    httpProxy = require('http-proxy'),
    transformerProxy = require('transformer-proxy'),
    serveStatic = require('serve-static'),
    finalhandler = require('finalhandler'),
    errorhandler = require('errorhandler'),
    Instrumenter = require('./dist/scripts/instrumentation/Instrumenter.js');

var proxiedPort = 3000;
var proxyPort = 8013;

var app = connect();
var proxy = httpProxy.createProxyServer({target: 'http://localhost:' + proxiedPort});
var transformer = transformerProxy(transformerFunction);
var serve = serveStatic("dist");
var instrumenter = new Instrumenter();

app.use(errorhandler());

app.use(function(req, res, next) {
  if (!isNativeCode(req) && isJavaScript(req)) {
    transformer(req, res, next);
  } else {
    next();
  }
});

app.use(function(req, res) {
  if (isNativeCode(req)) {
    req.url = req.url.replace("analyzejs/", "");
    serve(req, res, finalhandler(req, res));
  } else {
    proxy.web(req, res);
  }
});

http.createServer(app).listen(proxyPort);


console.log("The proxied server listens on",  proxiedPort);
console.log("The proxy server listens on",  proxyPort);

process.on('uncaughtException', function(msg) {
  console.log("error:", msg);
});



function transformerFunction(data, fileName) {
  // TODO: change transformer-proxy so that fileName will be passed
  return instrumenter.instrument(data.toString(), fileName).toString();
}

function isNativeCode(req) {
  return req.url.indexOf("analyzejs/") > -1;
}

function isJavaScript(req) {
  return /\.js([^\w]|$)/.test(req.url);
}
