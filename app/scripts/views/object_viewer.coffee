### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
../Formatter : Formatter
###

ObjectViewer = React.createClass

  getInitialState : ->

    searchQuery : ""

  handleSearch : (searchQuery) ->

    @setState {searchQuery}

  getElementsForObject : (obj) ->

    eval(withReact.import)
    for own prop, value of obj
      li { onClick : -> console.log(value) },
        "#{prop} : #{Formatter.formatValue value}"

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

