--Create the database wash_ev_sales
CREATE DATABASE wash_ev_sales;

--Create table for the csv file to be loaded into
--Changed vin and model_year into text
CREATE TABLE ev_population_data(
    vin INT,
    county VARCHAR(30),
    city VARCHAR(30),
    state VARCHAR(2),
    postal_code INT,
    model_year DATE,
    make TEXT,
    model TEXT,
    electric_vehicle_type TEXT,
    cafv_elegibility TEXT,
    range INT,
    base_msrp INT,
    legislative_district INT,
    dol_vehicle_id INT,
    vehicle_location TEXT,
    electric_utility TEXT,
    census_tract TEXT
);

--Set ownership of tables to postgres user
ALTER TABLE ev_population_data OWNER to postgres;


--Alter datatypes to allow data to be loaded
ALTER TABLE ev_population_data
ALTER COLUMN vin TYPE TEXT; 
ALTER TABLE ev_population_data
ALTER COLUMN model_year TYPE TEXT;

--Load csv data into table
COPY ev_population_data
FROM 'C:\Users\chris\Desktop\SQL\EV_Sales_WA_SQL\Electric_Vehicle_Population_Data.csv'
DELIMITER ','
CSV HEADER;

--Check to see if load worked
SELECT *
FROM
    ev_population_data
LIMIT 10;