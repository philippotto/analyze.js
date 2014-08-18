### define
react : React
react-bootstrap : ReactBootstrap
###


R = _.merge(_.merge({}, ReactBootstrap), React.DOM)
eval(Object.keys(R).map((k) -> unless k is "var" then "var #{k} = R['#{k}']").join("; "))

ObjectViewer = React.createClass

  getInitialState : ->

    searchQuery : ""

  handleSearch : (searchQuery) ->

    @setState {searchQuery}

  formatValue : (value) ->

    switch typeof value
      when "string" then "\"#{value}\""
      when "function" then "function"
      when "object" then "object"


  getElementsForObject : (obj) ->

    for own prop, value of obj
      li {},
        "#{prop} : #{@formatValue value}"

  render : ->

    obj = @props.object

    children = obj.map(@getElementsForObject)
    children.push(@getElementsForObject( "prototype" : obj.__proto__))

    style =
      "padding-left" : "15px"
      overflow : "auto"


    ul {style},
      children



ObjectViewer
