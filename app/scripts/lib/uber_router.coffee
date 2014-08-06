### define
jquery : $
backbone : Backbone
###

class UberRouter extends Backbone.Router

  whitelist : []

  initialize : ->

    @$rootEl = $(@rootSelector)
    @$navbarEl = $(@navbarSelector)
    @activeViews = null


  changeView : (views...) ->

    # Remove current views
    if @activeViews
      for view in @activeViews
        # prefer Marionette's close() function to Backbone's remove()
        if view.close
          view.close()
        else
          view.remove()
    else
      # we are probably coming from a URL that isn't a Backbone.View yet (or page reload)
      @$rootEl.empty()

    # Add new views
    @activeViews = views

    for view in views
      @$rootEl.append(view.render().el)

    return


  changeTitle : (title) ->
    window.document.title = title
    return


  changeActiveNavbarItem : (url) ->
    @$navbarEl
      .find(".active")
      .removeClass("active")
    if url
      @$navbarEl
        .find("a[href=\"#{url}\"]")
        .closest("li")
        .addClass("active")
    return


  handlePageLinks  : ->
    # handle all links and manage page changes (rather the reloading the whole site)
    $(document).on("click", "a", (evt) =>

      url = $(evt.currentTarget).attr("href")
      if url == "#"
        return

      if _.contains(@whitelist, url)
        return

      urlWithoutSlash = url.slice(1)
      if @routes[urlWithoutSlash]
        evt.preventDefault()
        @navigate(url, trigger : true)

      return
    )
