### define
###

class JSFunction

  constructor : (@id, @fileURL, @source, @name, @params) ->

  getSourceString : -> @source

  getFileURL : -> @fileURL

  getName : -> @name

  getParameters : -> @params

  matches : (filter) ->

    props =
      name : @getName()
      path : @getFileURL()
      source : @getSourceString()
      params : @getParameters()

    return filter(props)
