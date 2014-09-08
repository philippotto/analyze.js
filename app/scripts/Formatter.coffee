### define
###

Formatter =
  formatValue : (value) ->

    switch typeof value
      when "string" then "\"#{value}\""
      when "function" then "function"
      when "object" then "object"
      when "number" then value
      else value
