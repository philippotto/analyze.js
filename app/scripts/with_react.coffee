### define
react : React
react-bootstrap : ReactBootstrap
###


R = _.merge(_.merge({}, ReactBootstrap), React.DOM)

import : "var R = _.merge(_.merge({}, ReactBootstrap), React.DOM);" + Object.keys(R).map((k) -> unless k is "var" then "var #{k} = R['#{k}']").join("; ")
R : R
