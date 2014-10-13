# analyze.js [![Build Status](https://travis-ci.org/philippotto/analyze.js.svg?branch=master)](https://travis-ci.org/philippotto/analyze.js)

analyze.js is a tool to analyze applications which rely on node or JavaScript or any language which compiles to JavaScript.
The dynamic analysis process focuses on protocolling function invocations as well as determining module dependencies and various runtime characteristics.

analyze.js consists of:
- a back-end which proxies a local webapp and instruments requested JavaScript files on the fly
- a front-end which provides an overview of the analyzed characteristics

__analyze.js is currently work in progress.__


## Motivation

The main goal of analyze.js is to simplify understanding of code (especially in large code bases). Common use cases are  familiarizing with a project as well as refactoring, debugging and reverse engineering. Optimizing performance is also a possible use case, but it is not a central goal since there are already other very good tools faciliting this (especially the Chrome Dev Tools).


## How to use

Let's say you got an app running on localhost:proxiedPort. In order to analyze the app, analyze.js will create a proxy server (running on localhost:proxyPort), which you can visit to see the original app and the analyzation results.

Follow these steps to set up analyze.js:

- Checkout this repository (analyze.js isn't available via npm yet)
- cd into the project directory
- ```npm install```
- ```gulp watch --proxiedPort proxiedPort --proxyPort proxyPort```
- Visit __[localhost:3000/analyze.js/](http://localhost:proxyPort/analyze.js/)__ in your browser (preferably Chrome; other browsers are not tested, yet)

## License

MIT © Philipp Otto 2014
