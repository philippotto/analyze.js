### define
###

class JSFunction

  constructor : (@id, @fileURL, @source, @name, @params) ->

  getSourceString : -> @source

  getFileURL : -> @fileURL

  getName : -> @name

  getParameters : -> @params

  matches : (query) ->

    return _.any([@getName(), @getFileURL()], (property) ->
      property.toLowerCase().indexOf(query.toLowerCase()) > -1
    )
