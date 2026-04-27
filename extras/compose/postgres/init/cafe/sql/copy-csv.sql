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

-- Aufruf:   psql --dbname=buch --username=postgres --file=/init/buch/sql/copy-csv.sql

SET search_path TO cafe;

-- https://www.postgresql.org/docs/current/sql-copy.html
COPY cafe FROM '/init/cafe/csv/cafe.csv' (FORMAT csv, DELIMITER ';', HEADER true);
COPY cafe_manager FROM '/init/cafe/csv/cafe_manager.csv' (FORMAT csv, DELIMITER ';', HEADER true);
COPY produkt FROM '/init/cafe/csv/produkt.csv' (FORMAT csv, DELIMITER ';', HEADER true);
