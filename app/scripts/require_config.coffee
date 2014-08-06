require.config(

  baseUrl : "scripts"
  waitSeconds : 15

  paths :
    lodash : "../bower_components/lodash/dist/lodash"
    backbone : "../bower_components/backbone/backbone"
    marionette : "../bower_components/marionette/lib/backbone.marionette"
    jquery : "../bower_components/jquery/dist/jquery"
    falafel : "../bower_components/falafel/index"
    esprima : "../bower_components/esprima/esprima"
    react : "../bower_components/react/react"
    foundation : "../bower_components/foundation/js/foundation"

  map :
    backbone :
      underscore : "lodash"
    marionette :
      underscore : "lodash"


  shim :
    "jquery.easie" :
      deps : [ "jquery" ]
    "jquery.transit" :
      deps : [ "jquery" ]
    "inflate" :
      exports : "Zlib"
    "vendor/analytics" :
      exports : "ga"
    "falafel" :
      deps: ["esprima"]
      exports: "module.exports"

)