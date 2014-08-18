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

  getElementsForObject : (obj) ->

    for own prop, value of obj
      li {},
        "#{prop} : #{value}"

  render : ->

    obj = @props.object

    children = _.flatten(obj.map(@getElementsForObject))

    style =
      "padding-left" : "15px"
      overflow : "auto"


    ul {style},
      children



ObjectViewer
