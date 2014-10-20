falafel = require("falafel")
_ = require("lodash")
fs = require('fs')

class Instrumenter

  isBlacklisted : (fileURL)  ->

    @blacklist ||= fs.readFileSync('blacklist.txt', 'utf8')
      .split("\n")
      .map((el) -> el.trim())

    return fileURL and _.any(@blacklist, (el) -> el and fileURL.indexOf(el) > -1)


  instrument : (codeString, fileURL) ->

    if @isBlacklisted(fileURL)
      console.log("don't instrument blacklisted", fileURL)
      return codeString

    try
      return falafel(codeString, (node) =>

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

    catch e
      console.error("error at transforming", fileURL, "is it JavaScript? file will stay gracefully untouched.")
      return codeString


  generateMetaInfo : (codeString, fileURL, node, params) ->

    father = node.parent

    if not node.id?

      alternateName = switch father.type
        when "VariableDeclarator"
          # var a = function() {}
          father.id.name
        when "Property"
          # { a : function() {} }
          father.key.name
        when "MemberExpression"
          grandpa = father.parent
          greatGrandpa = grandpa.parent

          if grandpa.type == "CallExpression"
            if greatGrandpa.type == "VariableDeclarator"
              # something like var a = function() {}.bind(this)
              greatGrandpa.id.name
            else if greatGrandpa.type == "Property"
              # something like {a : function() {}.bind(this)}
              greatGrandpa.key.name

      alternateName ||= "anonymousFn"


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
