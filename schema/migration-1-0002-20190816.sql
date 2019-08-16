-- Hand written migration to create the custom types with 'DOMAIN' statements.

CREATE FUNCTION migrate() RETURNS void AS $$

DECLARE
  next_version int;

BEGIN
  SELECT stage_one + 1 INTO next_version FROM "schema_version";
  IF next_version = 2 THEN
    -- Blocks, transactions and merkel roots use a 32 byte hash.
    EXECUTE 'CREATE DOMAIN hash32type AS bytea CHECK (octet_length (VALUE) = 32);';
    -- Addresses use a 28 byte hash.
    EXECUTE 'CREATE DOMAIN hash28type AS bytea CHECK (octet_length (VALUE) = 28);';

	-- Drop this view if because this migration changes types of columns the view
	-- referred to. We can recreate the view later in the migration schedule.
    EXECUTE 'DROP VIEW IF EXISTS utxo;';

    UPDATE "schema_version" SET stage_one = 2;
    RAISE NOTICE 'DB has been migrated to stage_one version %', next_version;
  END IF;
END;

$$ LANGUAGE plpgsql;

SELECT migrate();

DROP FUNCTION migrate();
