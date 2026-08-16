export function formatDuration(seconds) {
  const m = Math.floor(seconds / 60);
  return `${m}m`;
}

export function parse(text) {
  return Number(text.replace(/[^0-9]/g, ""));
}

export function toSeconds(minutes) {
  return minutes * 60;
}
