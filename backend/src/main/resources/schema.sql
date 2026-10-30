-- Convert the legacy H2 native ENUM column to VARCHAR so all BookingStatus values
-- (including PENDING, ACCEPTED and REJECTED) can be stored. IF EXISTS makes this
-- safe on a brand-new database where Hibernate will create the table afterward.
ALTER TABLE IF EXISTS bookings ALTER COLUMN status SET DATA TYPE VARCHAR(20);
