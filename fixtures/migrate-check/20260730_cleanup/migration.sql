-- FIXTURE — two destructive statements the classification must mark
DROP TABLE legacy_sessions;
ALTER TABLE orders RENAME COLUMN total TO total_amount;
