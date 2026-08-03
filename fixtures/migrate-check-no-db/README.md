# no-database fixture (/migrate-check autodetect, task 4.39)

A small, ordinary project that has **no database of any kind**. It exists so
`/migrate-check` can be shown opening with *"no database in this project —
nothing to pre-flight"* instead of reaching that answer the long way through
a failed migration-stack lookup.

What it deliberately omits — the signals the autodetect keys on:

- no `prisma/` and no migrations directory
- no `.sql` file anywhere
- no Python or Ruby migration config
- no ORM or database-driver dependency in the manifest
- no database connection string in an env file

**Do not add any of the above.** `scripts/controls.sh` asserts this fixture
stays signal-free: the fixture's value IS the absence, so a single stray
signal silently converts it into a fixture that tests nothing. Note the
control greps the whole directory, so avoid spelling the literal signal
tokens even in prose — that is a false positive this fixture already caused
once, and the loud failure is preferable to a quiet one.
