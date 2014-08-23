var util = require('util'),
    colors = require('colors'),
    http = require('http'),
    connect = require('connect'),
    st = require('connect-static-transform'),
    httpProxy = require('http-proxy');

var proxiedPort = 3000;
var proxyPort = 8013;

var app = connect();
var proxy = httpProxy.createProxyServer({target: 'http://localhost:' + proxiedPort});

var transformerFunction = function(data) {
  return data + " // tschakalaka";
}

app.use(transformerInjector(transformerFunction, {match : /\.js([^\w]|$)/}));
app.use(function(req, res) {
  proxy.web(req, res);
});

http.createServer(app).listen(proxyPort);

util.puts('http proxy server'.blue + ' started '.green.bold + 'on port '.blue + (proxyPort + '').yellow);
util.puts('proxying http server '.blue + 'on port '.blue + (proxiedPort + '').yellow);


var TransformerStream = function (transformerFunction) {
  this.readable = true;
  this.writable = true;
  this.transformerFunction = transformerFunction;
};

require("util").inherits(TransformerStream, require("stream"));

TransformerStream.prototype._transform = function (data) {
  data = data ? this.transformerFunction(data.toString()) : "";
  this.emit("data", data);
};

TransformerStream.prototype.write = function () {
  this._transform.apply(this, arguments);
};

TransformerStream.prototype.end = function () {
  this._transform.apply(this, arguments);
  this.emit("end");
};


function transformerInjector(transformerFunction, options) {

  if (!options) {
    options = {};
  }

  var identity = function(data) { return data };

  return function transformerInjector(req, res, next) {

    var identityOrTransformer = transformerFunction;
    if (options.match && !options.match.test(req.url)) {
      identityOrTransformer = identity;
    }

    var transformerStream = new TransformerStream(identityOrTransformer);

    var resWrite = res.write.bind(res);
    var resEnd = res.end.bind(res);
    var resWriteHead = res.writeHead.bind(res);

    res.write = function (data, encoding) {
      transformerStream.write(data, encoding);
    };

    res.end = function (data, encoding) {
      transformerStream.end(data, encoding);
    };

    transformerStream.on('data', function (buf) {
      resWrite(buf);
    });

    transformerStream.on('end', function () {
      resEnd();
    });

    res.writeHead = function (code, headers) {
        res.removeHeader('Content-Length');
        if (headers) { delete headers['content-length']; }
        resWriteHead.apply(null, arguments);
    };

    next();
  }
}
