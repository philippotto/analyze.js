### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
./object_viewer : ObjectViewer
filtrex : filtrex
###

R = withReact.R


NavigationView = React.createClass

  handleSearch : ->

    searchExpression = @refs.searchInput.getValue()
    contains = (a, b) -> a.indexOf(b) > -1

    try
      filter = filtrex(searchExpression, {c : contains})
    catch e
      filter = -> true

    @props.setSearch(searchExpression, filter)


  render : ->

    brand = R.a href:"#", className:"navbar-brand",
      "analyze.js"

    R.Navbar {inverse: true, brand, fluid : true},
      R.Nav {},
        R.form className : "navbar-form navbar-left", role : "search",
          R.div className : "form-group",
            R.Input {
              type: "text"
              className : "form-control"
              style :
                width : 300
              placeholder: "Search"
              onChange: @handleSearch
              value: @props.searchQuery
              ref: "searchInput"
            }
