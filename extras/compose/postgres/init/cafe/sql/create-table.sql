-- Copyright (C) 2022 - present Juergen Zimmermann, Hochschule Karlsruhe
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Aufruf:   psql --dbname=cafe --username=cafe --file=/init/cafe/sql/create-table.sql

-- text statt varchar(n):
-- "There is no performance difference among these three types, apart from a few extra CPU cycles
-- to check the length when storing into a length-constrained column"
-- ggf. CHECK(char_length(name) <= 255)

-- Indexe auflisten:
-- psql --dbname=cafe --username=cafe
--  SELECT   tablename, indexname, indexdef, tablespace
--  FROM     pg_indexes
--  WHERE    schemaname = 'cafe'
--  ORDER BY tablename, indexname;
--  \q

-- https://www.postgresql.org/docs/current/manage-ag-tablespaces.html
SET default_tablespace = cafespace;

-- https://www.postgresql.org/docs/current/app-psql.html
-- https://www.postgresql.org/docs/current/ddl-schemas.html
-- https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-CREATE
-- "user-private schema" (Default-Schema: public)
CREATE SCHEMA IF NOT EXISTS AUTHORIZATION cafe;

ALTER ROLE cafe SET search_path = 'cafe';
set search_path to 'cafe';

-- https://www.postgresql.org/docs/current/sql-createtype.html
-- https://www.postgresql.org/docs/current/datatype-enum.html
CREATE TYPE kaffeeart AS ENUM ('ESPRESSO', 'CAPPUCCINO', 'LATTE_MACCHIATO', 'AMERICANO', 'FLAT_WHITE', 'COLD_BREW', 'MATCHA');

-- https://www.postgresql.org/docs/current/sql-createtable.html
-- https://www.postgresql.org/docs/current/datatype.html
CREATE TABLE IF NOT EXISTS cafe (
                  -- https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-INT
                  -- https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-PRIMARY-KEYS
                  -- impliziter Index fuer Primary Key
                  -- "GENERATED ALWAYS AS IDENTITY" gemaess SQL-Standard
                  -- entspricht SERIAL mit generierter Sequenz cafe_id_seq
    id              integer GENERATED ALWAYS AS IDENTITY(START WITH 1000) PRIMARY KEY,
                  -- https://www.postgresql.org/docs/current/ddl-constraints.html#id-1.5.4.6.6
    version         integer NOT NULL DEFAULT 0,
    name            text NOT NULL,
                  -- impliziter Index als B-Baum durch UNIQUE
                  -- https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS
    email           text NOT NULL UNIQUE,
                  -- https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-CHECK-CONSTRAINTS
    kategorie       integer NOT NULL CHECK (kategorie >= 1 AND kategorie <= 9),
                  -- https://www.postgresql.org/docs/current/datatype-datetime.html
    gruendungsdatum date NOT NULL,
                  -- https://www.postgresql.org/docs/current/datatype-enum.html
    kaffeeart       kaffeeart,
                  -- https://www.postgresql.org/docs/current/datatype-json.html
    kaffeesorten    jsonb DEFAULT '[]'::jsonb,
    username        text,
                  -- https://www.postgresql.org/docs/current/datatype-datetime.html
    erzeugt         timestamp NOT NULL DEFAULT NOW(),
    aktualisiert    timestamp NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cafe_manager (
    id          integer GENERATED ALWAYS AS IDENTITY(START WITH 1000) PRIMARY KEY,
    vorname     text NOT NULL,
    nachname    text NOT NULL,
                -- https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK
    cafe_id     integer NOT NULL UNIQUE REFERENCES cafe ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS produkt (
    id          integer GENERATED ALWAYS AS IDENTITY(START WITH 1000) PRIMARY KEY,
    name        text NOT NULL,
                -- https://www.postgresql.org/docs/current/datatype-numeric.html#DATATYPE-NUMERIC-DECIMAL
                -- 10 Stellen, davon 2 Nachkommastellen
    preis       decimal(10,2) NOT NULL,
    waehrung    text NOT NULL,
                -- https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-FK
    cafe_id     integer NOT NULL REFERENCES cafe ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS produkt_cafe_id_idx ON produkt(cafe_id);
