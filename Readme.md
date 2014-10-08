# analyze.js [![Build Status](https://travis-ci.org/philippotto/analyze.js.svg?branch=master)](https://travis-ci.org/philippotto/analyze.js)

analyze.js is a tool to analyze applications which rely on node or JavaScript or any language which compiles to JavaScript.
The dynamic analysis process focuses on protocolling function invocations as well as determining module dependencies and various runtime characteristics.

analyze.js consists of:
- a back-end which proxies a local webapp and instruments requested JavaScript files on the fly
- a front-end which provides an overview of the analyzed characteristics

analyze.js is currently work in progress.


## How to use

- Checkout this repository (analyze.js isn't available via npm yet)
- cd into the project directory
- ```npm install```
- ```gulp watch --proxiedPort 4000 --proxyPort 3000```
  - This assumes, the app you want to analyze runs on port 4000.
- Visit [localhost:3000/analyze.js/](http://localhost:3000/analyze.js/) in your browser (preferably Chrome; other browsers are not tested, yet)
  - If you changed --proxyPort when running gulp, adapt the port number accordingly.

## License

MIT © Philipp Otto 2014
