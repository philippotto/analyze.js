### define
###

class JSFunction

  constructor : (@id, @fileName, @node, @params) ->


  getSourceString : -> @node.source()

  getFileName : -> @fileName

  getName : -> @node.id.name

  getParameters : -> @params

  matches : (query) ->

    _.any([@getName(), @getFileName()], (property) ->
      property.toLowerCase().indexOf(query.toLowerCase()) > -1
    )

JSFunction
