-- Music database: schema + data (idempotent)
\ir 00_check_primary.sql

SELECT 'CREATE DATABASE music'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'music')\gexec

\c music

DO $$
BEGIN
    IF pg_is_in_recovery() THEN
        RAISE EXCEPTION 'Run this on primary only. Current node is in recovery.';
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS Artists (
    artistID smallint PRIMARY KEY,
    name varchar(20),
    city varchar(10),
    country varchar(10),
    style varchar(20)
);

CREATE TABLE IF NOT EXISTS Albums (
    albumID smallint PRIMARY KEY,
    name varchar(30),
    format varchar(20),
    year smallint,
    online_stores varchar(20),
    artistID smallint
);

INSERT INTO Artists (artistID, name, city, country, style) VALUES
    (1, 'Bill Evans', 'New York', 'USA', 'jazz'),
    (2, 'Juliette Jade', 'Paris', 'France', 'rock'),
    (3, 'Didier Lookwood', 'Paris', 'France', 'jazz'),
    (4, 'Diana Krall', 'New York', 'USA', 'jazz')
ON CONFLICT (artistID) DO NOTHING;

INSERT INTO Albums (albumID, name, format, year, online_stores, artistID) VALUES
    (1, 'Tribute to Stephane Grappelli', 'CD', 2000, 'fnac', 3),
    (2, 'Constellation', 'digital vinyl', 2018, 'bandcamp', 2),
    (3, 'Kaleidoscope', 'digital', 2021, 'bandcamp', 2),
    (4, 'You must believe in spring', 'digital vinyl', 2004, 'fnac', 1),
    (5, 'Live in Paris', 'CD', 2002, 'amazon', 4)
ON CONFLICT (albumID) DO NOTHING;
