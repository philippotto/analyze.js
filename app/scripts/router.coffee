### define
jquery : $
backbone : Backbone
lib/uber_router : UberRouter
analyze : Analyze
###

class Router extends UberRouter

  rootSelector : "#main"
  navbarSelector : "#navbar"

  routes :
    "analyzejs/index.html" : "home"
    "analyzejs/" : "home"

  whitelist : []

  home : ->

    view = new Backbone.View()
    view.render()
    view.$el.html("")
    @changeView(view)

    Analyze()
