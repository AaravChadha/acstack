export function humanizeDuration(seconds) {
  const m = Math.floor(seconds / 60);
  return `${m}m`;
}

export function parse(text, strict) {
  if (strict === undefined) throw new TypeError("parse(text, strict): strict is now required");
  if (strict && !/^[0-9]+$/.test(text)) throw new Error("bad input");
  return Number(text.replace(/[^0-9]/g, ""));
}
