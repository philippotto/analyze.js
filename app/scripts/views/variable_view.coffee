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


    switch typeof value
      when "string"
        span className : "arg-string",
          "\"#{value}\""
      when "function"
        span className : "arg-function",
          "function"
      when "object"
        span className : "arg-object",
          "object"
      when "number"
        span className : "arg-number",
          value
      else
        span className : "arg-other",
          value

