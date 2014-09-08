var http = require('http'),
    connect = require('connect'),
    httpProxy = require('http-proxy'),
    transformerProxy = require('transformer-proxy'),
    serveStatic = require('serve-static'),
    finalhandler = require('finalhandler'),
    errorhandler = require('errorhandler');

var proxiedPort = 3000;
var proxyPort = 8013;

var app = connect();
var proxy = httpProxy.createProxyServer({target: 'http://localhost:' + proxiedPort});
var transformer = transformerProxy(transformerFunction);
var serve = serveStatic("dist");


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

process.on('uncaughtException', console.log.bind(console));



function transformerFunction(data) {
  return data + "\n window.opener.analyzejs.postMessage('hello');";
}

function isNativeCode(req) {
  return req.url.indexOf("analyzejs/") > -1;
}

function isJavaScript(req) {
  return /\.js([^\w]|$)/.test(req.url);
}
