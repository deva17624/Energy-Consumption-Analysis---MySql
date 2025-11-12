-- ===========================================================
--  ENERGY DATABASE 
-- ===========================================================

-- 2️ Create fresh database and use it
CREATE DATABASE energydb9;
USE energydb9;

-- 3️ Create COUNTRY_3 table (central master table)
CREATE TABLE COUNTRY_3 (
    Country VARCHAR(100) PRIMARY KEY,
    CID VARCHAR(10)
);

-- 4️ Create emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
    `energy type` VARCHAR(100),
    year INT,
    emission INT,
    `per capita emission` DOUBLE,
    FOREIGN KEY (country) REFERENCES COUNTRY_3(Country)
);

-- 5️ Create consum_3 table
CREATE TABLE consum_3 (
    country VARCHAR(100),
    energy VARCHAR(100),
    year INT,
    consumption INT,
    FOREIGN KEY (country) REFERENCES COUNTRY_3(Country)
);

-- 6️ Create production_3 table
CREATE TABLE production_3 (
    country VARCHAR(100),
    energy VARCHAR(100),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES COUNTRY_3(Country)
);

-- 7️ Create gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES COUNTRY_3(Country)
);

-- 8️ Create population_3 table
CREATE TABLE population_3 (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES COUNTRY_3(Country)
);

-- ===========================================================
--  Verification Section
-- ===========================================================

-- Show tables created
SHOW TABLES;

-- Verify foreign key relationships
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE REFERENCED_TABLE_NAME = 'COUNTRY_3' 
AND TABLE_SCHEMA = 'energydb9';

-- ===========================================================
-- 🧮 Example Data Validation Queries (Run after inserting data)
-- ===========================================================

-- Data count check
SELECT 'COUNTRY_3' as table_name, COUNT(*) as count FROM COUNTRY_3
UNION ALL SELECT 'emission_3', COUNT(*) FROM emission_3
UNION ALL SELECT 'consum_3', COUNT(*) FROM consum_3
UNION ALL SELECT 'production_3', COUNT(*) FROM production_3
UNION ALL SELECT 'gdp_3', COUNT(*) FROM gdp_3
UNION ALL SELECT 'population_3', COUNT(*) FROM population_3;

-- Test join (example)
SELECT c.Country, e.`energy type`, e.emission 
FROM COUNTRY_3 c 
JOIN emission_3 e ON c.Country = e.country 
LIMIT 5;

-- ===========================================================
-- 🔍 Analytical Queries (Run after data insertion)
-- ===========================================================

-- 1) Total emission per country (most recent year)
SELECT country, SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;

-- 2) Top 5 countries by GDP (latest year)
SELECT Country, Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY Value DESC
LIMIT 5;

-- 3) Compare energy production vs consumption
SELECT 
    p.country,
    p.year,
    SUM(p.production) AS Total_production,
    SUM(c.consumption) AS Total_consumption,
    (SUM(p.production) - SUM(c.consumption)) AS net_balance
FROM production_3 p
INNER JOIN consum_3 c ON p.country = c.country AND p.year = c.year
GROUP BY p.country, p.year
ORDER BY p.year, p.country;

-- 4) Energy types contributing most to emissions
SELECT `energy type`, SUM(emission) AS total_emission
FROM emission_3
GROUP BY `energy type`
ORDER BY total_emission DESC;

-- 5) Global emissions trend (yearly)
SELECT year, SUM(emission) AS total_emission
FROM emission_3
GROUP BY year
ORDER BY year ASC;

-- 6) GDP trend per country
SELECT Country, year, Value AS GDP
FROM gdp_3
ORDER BY Country, year;

-- 7) Population vs total emissions
SELECT 
    p.countries, 
    p.year, 
    MAX(p.Value) AS population,
    SUM(e.emission) AS total_emission
FROM population_3 p
JOIN emission_3 e ON p.countries = e.country AND p.year = e.year
GROUP BY p.countries, p.year
ORDER BY p.countries, p.year;

-- 8) Top 5 economies — energy consumption over years
WITH top5 AS (
  SELECT Country
  FROM gdp_3
  WHERE year = (SELECT MAX(year) FROM gdp_3)
  ORDER BY Value DESC
  LIMIT 5
)
SELECT c.country, c.year, SUM(c.consumption) AS total_consumption
FROM consum_3 c
JOIN top5 t ON c.country = t.Country
GROUP BY c.country, c.year
ORDER BY c.country, c.year;

-- 9) Emission-to-GDP ratio per country
SELECT e.country, e.year,
       SUM(e.emission) AS total_emission,
       g.Value AS GDP,
       ROUND(SUM(e.emission)/g.Value, 6) AS emission_to_gdp
FROM emission_3 e
JOIN gdp_3 g ON e.country = g.Country AND e.year = g.year
GROUP BY e.country, e.year, g.Value
ORDER BY emission_to_gdp DESC;

-- 10) Energy consumption per capita (last decade)
SELECT c.country, c.year,
       SUM(c.consumption) AS total_consumption,
       p.Value AS population,
       ROUND(SUM(c.consumption)/p.Value, 6) AS consumption_per_capita
FROM consum_3 c
JOIN population_3 p ON c.country = p.countries AND c.year = p.year
WHERE c.year BETWEEN (SELECT MAX(year)-9 FROM consum_3) AND (SELECT MAX(year) FROM consum_3)
GROUP BY c.country, c.year, p.Value
ORDER BY c.country, c.year;

-- 11) Energy production per capita
SELECT p.country, p.year, SUM(p.production) AS total_production,
       pop.Value AS population,
       ROUND(SUM(p.production)/pop.Value, 6) AS production_per_capita
FROM production_3 p
JOIN population_3 pop ON p.country = pop.countries AND p.year = pop.year
GROUP BY p.country, p.year, pop.Value
ORDER BY production_per_capita DESC;

-- 12) Highest energy consumption relative to GDP (latest year)
SELECT c.country, c.year,
       SUM(c.consumption) AS total_consumption,
       g.Value AS GDP,
       ROUND(SUM(c.consumption)/g.Value, 6) AS cons_to_gdp
FROM consum_3 c
JOIN gdp_3 g ON c.country = g.Country AND c.year = g.year
WHERE c.year = (SELECT MAX(year) FROM consum_3)
GROUP BY c.country, c.year, g.Value
ORDER BY cons_to_gdp DESC
LIMIT 10;

-- 13) Correlation: GDP vs Energy Production Growth
WITH gdp_growth AS (
  SELECT Country, year,
         (Value - LAG(Value) OVER (PARTITION BY Country ORDER BY year))
         / LAG(Value) OVER (PARTITION BY Country ORDER BY year) AS gdp_growth
  FROM gdp_3
),
prod_growth AS (
  SELECT country, year,
         (SUM(production) - LAG(SUM(production)) OVER (PARTITION BY country ORDER BY year))
         / LAG(SUM(production)) OVER (PARTITION BY country ORDER BY year) AS prod_growth
  FROM production_3
  GROUP BY country, year
)
SELECT g.Country,
       ROUND(AVG(g.gdp_growth),4) AS avg_gdp_growth,
       ROUND(AVG(p.prod_growth),4) AS avg_prod_growth
FROM gdp_growth g
JOIN prod_growth p ON g.Country = p.country AND g.year = p.year
GROUP BY g.Country
ORDER BY avg_gdp_growth DESC;

-- 14) Top 10 countries by population and their emissions
SELECT p.countries, p.Value AS population,
       COALESCE(SUM(e.emission),0) AS total_emission
FROM population_3 p
LEFT JOIN emission_3 e ON p.countries = e.country AND p.year = e.year
WHERE p.year = (SELECT MAX(year) FROM population_3)
GROUP BY p.countries, p.Value
ORDER BY population DESC
LIMIT 10;

-- ===========================================================
-- ✅ END OF SCRIPT
-- ===========================================================