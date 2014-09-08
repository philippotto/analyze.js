### define
###

class JSFunction

  constructor : (@id, @fileName, @source, @name, @params) ->

  getSourceString : -> @source

  getFileName : -> @fileName

  getName : -> @name

  getParameters : -> @params

  matches : (query) ->

    _.any([@getName(), @getFileName()], (property) ->
      property.toLowerCase().indexOf(query.toLowerCase()) > -1
    )
