falafel = require("falafel")
_ = require("lodash")

class Instrumenter

  instrument : (codeString, fileURL) ->

    falafel(codeString, (node) =>

      parent = node.parent

      unless parent?.type in ["FunctionDeclaration", "FunctionExpression"] and node.type is "BlockStatement"
        return

      paramsAsStringArray = _.invoke(node.parent.params, "source")
      [fnID, fnProperties] = @generateMetaInfo(fileURL, parent, paramsAsStringArray)

      newCode =
        """{
        window.opener.app.tracer.traceEnter("#{fnID}", #{fnProperties}, arguments, this);
        var thrownException = null;
        try {
          var returnValue = (function(#{paramsAsStringArray.join(", ")}) {
            #{node.source()};
          }).apply(this, arguments);
        } catch(ex) {
          thrownException = ex;
        }
        window.opener.app.tracer.traceExit("#{fnID}", returnValue, thrownException);
        if(thrownException)
          throw thrownException;
        return returnValue;
        }"""

      node.update(newCode)

      try
        eval("throw Error('syntax_valid'); " + newCode)
      catch error
        if error.message != "syntax_valid"
          console.error("invalid code!!!")
          console.log(newCode)
    ).toString()


  generateMetaInfo : (fileURL, node, params) ->

    source = node.source()

    if not node.id?
      alternateName = switch node.parent.type
        when "VariableDeclarator"
          node.parent.id.name
        when "Property"
          node.parent.key.name
        else
          "anonymousFn"

      node.id =
        name : alternateName
        range : node.range

    name = node.id.name
    # TODO: check if node.id.range === node.range
    range = node.id.range

    fnID = [fileURL, name, range].join("-")
    fnProperties = JSON.stringify { fileURL, source, name, range, params }

    [fnID, fnProperties]


module.exports = Instrumenter



