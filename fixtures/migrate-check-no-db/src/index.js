// Fixture app for /migrate-check's no-database autodetect (task 4.39).
// Deliberately does nothing database-shaped: no client, no query, no URL.
import pc from 'picocolors';

export function greet(name) {
  if (typeof name !== 'string' || name.trim() === '') {
    throw new TypeError('name must be a non-empty string');
  }
  return pc.green(`hello, ${name.trim()}`);
}
