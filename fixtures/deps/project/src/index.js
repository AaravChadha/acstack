const objectAssign = require("object-assign");
const leftPad = require("left-pad");
const stamp = require("fixture-copyleft-lib");

function buildInvoice(base, overrides) {
  const merged = objectAssign({}, base, overrides);
  merged.ref = leftPad(String(merged.id), 8, "0");
  return stamp(merged);
}

module.exports = { buildInvoice };
