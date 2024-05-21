--Create copy of table in order to manipulate data without affecting the orignial
CREATE TABLE ev_population_data_staging AS
SELECT *
FROM 
    ev_population_data;

-- Create unique table id since VIN is only 10 digits instead of 17
ALTER TABLE ev_population_data_staging
ADD table_id SERIAL;


-- Stanardize data

SELECT 
  *
FROM
    ev_population_data_staging
LIMIT 100;

--Make all text in proper format

SELECT
    INITCAP(make),
    INITCAP(model)
FROM
    ev_population_data_staging
LIMIT 100;

UPDATE ev_population_data_staging
SET make = INITCAP(make);

UPDATE ev_population_data_staging
SET model = INITCAP(model);

-- Investigating duplicate values
SELECT 
    DISTINCT make
FROM
    ev_population_data_staging;
--All columns are filtered
--Investigate range(low/high range outliers)
SELECT 
    make,
    model,
    model_year,
    range
FROM
    ev_population_data_staging
WHERE
    range > '0';
--91950 rows of 0 range 

--Investigate base msrp
SELECT 
    COUNT(base_msrp)
FROM
    ev_population_data_staging
WHERE
    base_msrp <> '0'
-- 174522 rows of base_msrp being 0(probably means the data is unreliable to use)
-- 3344 rows of base_msrp not being 0

--Data pretty much cleaned

