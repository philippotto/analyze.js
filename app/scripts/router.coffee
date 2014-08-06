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
    "" : "home"

  whitelist : []

  home : ->

    view = new Backbone.View()
    view.render()
    view.$el.html("What up!")
    @changeView(view)

    # console.log("Analyze",  Analyze)
    Analyze()
