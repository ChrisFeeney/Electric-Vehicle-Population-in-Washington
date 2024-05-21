/* Questions
1. Which cities in Washington have the highest EV ownership? Which cities have the highest plug-in hybrid ownership?
2. What are the most popular makes of EVs owned in Washington? What are the most popular specific models of EVs owned in Washington?
What about Seattle?
3. Based upon model year what are the top 5 most popular makes each year?
4. Looking at strictly fully electric vehicles, what is the distribution of the ranges.
*/


SELECT *
FROM
    ev_population_data_staging
LIMIT 100;

SELECT 
    COUNT(vin)
FROM
    ev_population_data_staging;
--177866 total records

--Look at how many records per county
SELECT 
    county,
    COUNT(county) AS amount_per_county
FROM
    ev_population_data_staging
GROUP BY
    county
ORDER BY
    amount_per_county DESC;
--King county has the most at 92740 followed by snohomish at 21001

--Look at which city in King county has the most records
SELECT 
    city,
    COUNT(city) AS amount_per_city
FROM
    ev_population_data_staging
WHERE
    county = 'King'
GROUP BY
    city
ORDER BY
    amount_per_city DESC;
/*Seattle has the most at 29447, followed by Bellevue at 8930, then Redmond at 6478*/


--///////////////////////////////////////////////////////////////////////
-- 1.
--Looking at which city within the entire state has the most EVs
SELECT 
    city,
    COUNT(city) AS amount_per_city
FROM
    ev_population_data_staging
WHERE
    electric_vehicle_type = 'Battery Electric Vehicle (BEV)'
GROUP BY
    city
ORDER BY
    amount_per_city DESC;
--Seattle has the most, followed by Bellevue, Redmond, Bothell, and Sammamish.
/*While Seattle and Bellevue having the most amount of EVs makes sense given they are some of the most populated cities,
Redmond, Bothell, and Sammamish are the 17th, 21st and 26th most populace cities. */

--Looking at which city has the most plug in hybrids
SELECT 
    city,
    COUNT(city) AS amount_per_city
FROM
    ev_population_data_staging
WHERE
    electric_vehicle_type LIKE 'Plug-in Hybrid%'
GROUP BY
    city
ORDER BY
    amount_per_city DESC;
-- Seattle obviously has the most, but interestingly Tukwila, Vancouver, and Renton are next before Bellevue.



--Look at what the most popular car brands are
SELECT 
    make,
    COUNT(make)
FROM
    ev_population_data_staging
GROUP BY
    make
ORDER BY 
    COUNT(make) DESC
LIMIT 10;
-- Tesla is the most popular at nearly 80,000; next is Nissan at 13998; followed by Chevrolet.

--/////////////////////////////////////////////////////////////////////////////////////////////
--2.
--Looking more specifically at only evs
SELECT 
    make,
    COUNT(make) AS amount_of_evs
FROM
    ev_population_data_staging
WHERE
    electric_vehicle_type = 'Battery Electric Vehicle (BEV)'
GROUP BY
    make
ORDER BY
    amount_of_evs DESC
LIMIT 10;
-- The top 10 is Tesla at 79659, Nissian at 13998, Chevrolet at 8882,...

--Most popular individual cars
SELECT 
    model,
    COUNT(model) 
FROM
    ev_population_data_staging
WHERE
    electric_vehicle_type = 'Battery Electric Vehicle (BEV)'
GROUP BY
    model
ORDER BY
    COUNT(model) DESC;
--Model Y and Model 3 are far and away the most popular model of ev with around 35,000 each, followed by Leaf at 13366
--Four of the top six most popular models are tesla's; showcasing their domincance over the ev market in washington



--/////////////////////////////////////////////////////////////////////////////////////////////////////////////
--3.
--Look at the most popular evs per model year(with 2 CTE's)
WITH popular_ev_year AS(
    SELECT
        make, 
        model_year,
        COUNT(model) AS model_total
    FROM 
        ev_population_data_staging
    WHERE
        electric_vehicle_type = 'Battery Electric Vehicle (BEV)'
    GROUP BY
        make,
        model_year
    ORDER BY
        model_total DESC
), popular_ev_year_rank AS(
    SELECT
        *,
        DENSE_RANK() OVER(PARTITION BY model_year ORDER BY model_total DESC) AS ranking
    FROM
        popular_ev_year
)
SELECT 
    *
FROM
    popular_ev_year_rank
WHERE
    ranking <= 5
ORDER BY
    model_year DESC,
    ranking ASC;
/* 2024: BMW, Tesla, Kia, Audi, Hyundai
 2023: Tesla, Ford, Chevrolet, Rivian, Hyundai
 2022: Tesla, Kia, Ford, Rivian, Nissan
 2021: Tesla, Volkswagen, Ford, Nissan, Chevrolet
 This only shows the most popular car per model year; not the most popular car registered that year
 Tesla's cars from 2016-2023 (2014) have been the most popular evs in washington
*/

--///////////////////////////////////////////////////////////////////////////////////////////
--4.
--EV Range investigation
SELECT 
    range,
    count(model) AS amount_of_models_per_range
FROM    
    ev_population_data_staging
WHERE
    range <> '0' AND
    electric_vehicle_type = 'Battery Electric Vehicle (BEV)'
GROUP BY
    range
ORDER BY
    amount_of_models_per_range DESC;
/* 76 cars have the max amount of range at 337 miles
91950 cars have a reported 0 miles
215 miles has the most amount of cars with 6376, followed by 220 with 4115 and 238 with 3885
*/


-- Create 7 buckets of range(50 miles per bin) and the amount of cars in each bin
WITH range_bins AS(
SELECT
    WIDTH_BUCKET(range, 0, 350, 7) AS range_bucket,
    COUNT(*) AS count_of_cars
FROM
    ev_population_data_staging
WHERE
    range <> '0' AND
    electric_vehicle_type = 'Battery Electric Vehicle (BEV)'
GROUP BY
    WIDTH_BUCKET(range, 0, 350, 7)
)
SELECT
    CASE
        WHEN range_bucket = '1' THEN '0-49 Miles of Range'
        WHEN range_bucket = '2' THEN '50-99 Miles of Range'
        WHEN range_bucket = '3' THEN '100-149 Miles of Range'
        WHEN range_bucket = '4' THEN '150-199 Miles of Range'
        WHEN range_bucket = '5' THEN '200-249 Miles of Range'
        WHEN range_bucket = '6' THEN '250-299 Miles of Range'
        WHEN range_bucket = '7' THEN '300 + Miles of Range'
    END AS ranges,
    count_of_cars
FROM
    range_bins;
-- The most populated range group was 200-249 with 22989 cars
--Many of the range values were incorrecly inputed as 0 in the data set which limits the nominal amount of values but likely doesn't affect the spread


-- Check to make sure the buckets are set up at the correct interval
SELECT
    WIDTH_BUCKET(range, 0, 350, 7) AS range_bucket,
    range
FROM
    ev_population_data_staging
WHERE
    range <> '0' AND
    electric_vehicle_type = 'Battery Electric Vehicle (BEV)' AND
    WIDTH_BUCKET(range, 0, 350, 7) = '5'
GROUP BY
    range
ORDER BY
    range DESC;


