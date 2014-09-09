falafel = require("falafel")
_ = require("lodash")

class Instrumenter

  instrument : (codeString, fileName) ->

    falafel(codeString, (node) =>

      parent = node.parent

      # first two parts of condition could be enough?
      if parent?.type in ["FunctionDeclaration", "FunctionExpression"] and node.type is "BlockStatement"
        paramsAsStringArray = _.invoke(node.parent.params, "source")
        fnID = @createID(fileName, parent, paramsAsStringArray)



        newCode =   """{
                    window.opener.tracer.traceEnter(#{fnID}, arguments, this);
                    var thrownException = null;
                    try {
                      var returnValue = (function(#{paramsAsStringArray.join(", ")}) {
                        #{node.source()};
                      }).apply(this, arguments);
                    } catch(ex) {
                      thrownException = ex;
                    }
                    window.opener.tracer.traceExit(#{fnID}, returnValue, thrownException);
                    if(thrownException)
                      throw thrownException;
                    return returnValue;
                    }"""

        node.update newCode

        try
          eval("throw Error('syntax_valid'); " + newCode)
        catch error
          if error.message != "syntax_valid"
            console.error("invalid code!!!", newCode)
    )


  createID : (fileName, node, params) ->

    ###
    has to contain:
      + fileName
      + source
      + name
      (+ range)
      - params
   ###

    source = node.source()


    if not node.id?
      node.id =
        name : "anonymousFn"
        range : node.range

    name = node.id.name
    # TODO: check if node.id.range === node.range
    range = node.id.range

    complexID = { fileName, source, name, range, params }

    JSON.stringify(complexID)


module.exports = Instrumenter



