# Changelog — fixture-http-client

## 3.0.0

- **BREAKING:** the positional form `createClient(url, options)` is removed.
  Pass one options object: `createClient({ url, ...options })`. Deprecated
  since 2.4.0, warned since 2.5.0.
- **BREAKING:** `client.request(method, path)` is removed. Use
  `client.get(path)` or `client.post(path, body)`.
- Requires `fixture-retry` 2.x (was 1.x).

## 2.5.0

- Added `client.head(path)`.
- The positional `createClient(url, options)` form now logs a deprecation
  warning on first use.

## 2.4.1

- Fixed a retry-count off-by-one when `retries` is 0.

## 2.4.0

- `createClient` accepts a single options object, `{ url, ...options }`.
  The positional form is deprecated.
