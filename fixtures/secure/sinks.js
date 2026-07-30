// FIXTURE — the XSS sinks and dynamic-eval forms beyond innerHTML
document.write(userInput);
el.outerHTML = userInput;
el.insertAdjacentHTML("beforeend", userInput);
const f = new Function("return " + userInput);
eval(userInput);
require("child_process").exec("ls " + userInput);
