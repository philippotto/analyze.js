function a(arg1, callee) {
  if (callee == null)
    return "a" + b(arg1, "a is calling");
  return "a";
}

function b(arg1) {
  var mytext=document.createTextNode("some text");
  console.log("going to change the dom");
  document.body.appendChild(mytext);
  return "b" + c(arg1, "b is calling");
}

function c(arg1) {
  return "c" + a(arg1, "c is calling");
}


a('anArg');
a('anArg', 'anArg');