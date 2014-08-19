### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
###


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

    eval(withReact.import)
    for own prop, value of obj
      li { onClick : -> console.log(value) },
        "#{prop} : #{@formatValue value}"

  render : ->

    eval(withReact.import)
    obj = @props.object

    children = obj.map(@getElementsForObject)
    children.push(@getElementsForObject( "prototype" : obj.__proto__))

    style =
      "padding-left" : "15px"
      overflow : "auto"


    ul {style},
      children



ObjectViewer
