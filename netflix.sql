DROP DATABASE IF EXISTS NETFLIX;
CREATE DATABASE NETFLIX;
USE NETFLIX;
SELECT show_id, COUNT(*) AS count
FROM netflix
GROUP BY show_id
HAVING COUNT(*) > 1;
-- Count NULLs in Important Columns
SELECT 
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_nulls,
    SUM(CASE WHEN `title` IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_added_nulls,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls
FROM netflix;
-- Fill NULLs in director Where Cast Matches
UPDATE netflix 
SET director = 'Alastair Fothergill'
WHERE `title` = 'David Attenborough' AND director IS NULL;

-- Set remaining director NULLs as 'Not Given'
UPDATE netflix 
SET director = 'Not Given'
WHERE director IS NULL;
 -- Populate Country Using Matching Director Info
UPDATE netflix
JOIN netflix AS nt2 
ON netflix.director = nt2.director 
AND netflix.show_id <> nt2.show_id
SET netflix.country = nt2.country
WHERE netflix.country IS NULL;

-- Set remaining country NULLs as 'Not Given'
UPDATE netflix 
SET country = 'Not Given'
WHERE country IS NULL;
-- Delete Rows with NULLs in Critical Columns (Low Count)
-- Delete 10 rows where date_added is NULL
DELETE FROM netflix
WHERE date_added IS NULL;

-- Delete rows where rating is NULL
DELETE FROM netflix
WHERE rating IS NULL;

-- Delete rows where duration is NULL
DELETE FROM netflix
WHERE duration IS NULL;
-- Final NULL Check (All Columns Have Values)
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN show_id IS NULL THEN 1 ELSE 0 END) AS show_id_nulls,
    SUM(CASE WHEN `type` IS NULL THEN 1 ELSE 0 END) AS type_nulls,
    SUM(CASE WHEN title IS NULL THEN 1 ELSE 0 END) AS title_nulls,
    SUM(CASE WHEN director IS NULL THEN 1 ELSE 0 END) AS director_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN date_added IS NULL THEN 1 ELSE 0 END) AS date_added_nulls,
    SUM(CASE WHEN release_year IS NULL THEN 1 ELSE 0 END) AS release_year_nulls,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS rating_nulls,
    SUM(CASE WHEN duration IS NULL THEN 1 ELSE 0 END) AS duration_nulls,
    SUM(CASE WHEN listed_in IS NULL THEN 1 ELSE 0 END) AS listed_in_nulls
FROM netflix;
-- Drop Unnecessary Columns
ALTER TABLE netflix
DROP COLUMN `title`,
DROP COLUMN description;
-- Split Multi-Country Rows — Keep First Country Only
-- Add new column
ALTER TABLE netflix ADD country1 VARCHAR(255);

-- Store only first country
UPDATE netflix
SET country1 = TRIM(SUBSTRING_INDEX(country, ',', 1));

-- Replace original country
ALTER TABLE netflix DROP COLUMN country;
ALTER TABLE netflix RENAME COLUMN country1 TO country;
