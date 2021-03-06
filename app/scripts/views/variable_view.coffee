### define
react : React
react-bootstrap : ReactBootstrap
with_react : withReact
../Formatter : Formatter
###


R = withReact.R

VariableView = React.createClass

  render : ->

    eval(withReact.import)
    value = @props.data

    if _.isString(value)
      span className : "arg-string",
        "\"#{value}\""
    else if _.isFunction(value)
      span className : "arg-function",
        "Function"
    else if _.isArray(value)
      span className : "arg-array",
        "Array"
    else if _.isArguments(value)
      span className : "arg-arguments",
        "arguments"
    else if _.isDate(value)
      span className : "arg-date",
        value.toLocaleDateString()
    else if _.isNumber(value)
      span className : "arg-number",
        value
    else if _.isBoolean(value)
      span className : "arg-boolean",
        value + ""
    else if _.isUndefined(value)
      span className : "arg-undefined",
        "undefined"
    else if value == null
      span className : "arg-null",
        "null"
    else if _.isObject(value)
      span className : "arg-object",
        "Object"
    else
      span className : "arg-other",
        "Unknown Variable"

