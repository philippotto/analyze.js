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

analyze.js functions as a proxy so that web apps can be analyzed very easily without having to integrate in a certain build system or back-end.
Let's say you got an app running on localhost:proxiedPort. In order to analyze the app, analyze.js will create a proxy server (running on localhost:proxyPort), which you can visit to see the original app and the analyzation results.

Follow these steps to set up analyze.js:

- Checkout this repository (analyze.js isn't available via npm yet)
- cd into the project directory
- ```npm install```
- ```gulp watch --proxiedPort proxiedPort --proxyPort proxyPort```
- Visit __localhost:proxyPort/analyzejs/__ in your browser (preferably Chrome; other browsers are not tested, yet)
  - When the site is loaded, localhost:proxiedPort will be opened automatically in a new window (check your popup blocker!).

## FAQ

__When opening localhost:proxyPort, I get a ```Uncaught TypeError: Cannot read property 'app' of null``` error in the console?__

As it is stated in the "How to use" section, you have to visit __localhost:proxyPort/analyzejs/__.


__When opening localhost:proxyPort/analyzejs/, the page stays empty?__

Check your popup blocker. analyze.js will open localhost:proxyPort in a new window.


__Why aren't there any calls to jQuery/requireJS/XYZ?__

At the moment there is a blacklist of common libraries and frameworks which don't get instrumented. Since these JavaScript files tend to get called __very__ often and are usually not of interest, they will be ignored. This enhances performance when running the analyzed webapp and when rendering the front-end.


__Why is analyze.js so slow?__

Presumably, your webapp uses a library/framework which gets called __very__ often, but isn't blacklisted (see the previous question). Please open an issue. The blacklist will be configurable in the near future. Additionally, I'm working on tuning performance.


__Can I get notified about future releases of analyze.js?__

Yes! Visit this [issue](https://github.com/philippotto/analyze.js/issues/3) and click on "subscribe".


## License

MIT © Philipp Otto 2014
