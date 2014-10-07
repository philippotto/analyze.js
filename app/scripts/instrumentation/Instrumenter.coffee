falafel = require("falafel")
_ = require("lodash")

class Instrumenter

  instrument : (codeString, fileURL) ->

    falafel(codeString, (node) =>

      parent = node.parent

      unless parent?.type in ["FunctionDeclaration", "FunctionExpression"] and node.type is "BlockStatement"
        return

      paramsAsStringArray = _.invoke(node.parent.params, "source")
      [fnID, fnProperties] = @generateMetaInfo(codeString, fileURL, parent, paramsAsStringArray)

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


  generateMetaInfo : (codeString, fileURL, node, params) ->

    father = node.parent

    if not node.id?

      alternateName = switch father.type
        when "VariableDeclarator"
          father.id.name
        when "Property"
          father.key.name
        when "MemberExpression"
          # could be something like {a : function() {}.bind(this)}
          grandpa = father.parent
          greatGrandpa = grandpa.parent

          if grandpa.type == "CallExpression" and greatGrandpa.type == "Property"
            greatGrandpa.key.name
          else
            "anonymousFn"

        else
          "anonymousFn"

      node.id =
        name : alternateName

    name = node.id.name
    range = node.range

    # don't use node.source() to avoid saving the instrumented source
    source = "".slice.apply(codeString, range)

    fnID = [fileURL, name, range].join("-")
    fnProperties = JSON.stringify { fileURL, source, name, range, params }

    [fnID, fnProperties]


module.exports = Instrumenter
