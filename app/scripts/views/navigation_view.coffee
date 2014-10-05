### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
object_viewer : ObjectViewer

###

R = withReact.R


NavigationView = React.createClass

  handleSearch : ->

    searchQuery = @refs.searchInput.getValue()
    @props.onSearch(searchQuery)

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
              placeholder: "Search"
              onChange: @handleSearch
              value: @props.searchQuery
              ref: "searchInput"
            }
        R.DropdownButton key:3, title:"Dropdown",
          R.MenuItem key: "1",
            "Action"
          R.MenuItem divider : true
          R.MenuItem key: "4",
            "Separated link"
