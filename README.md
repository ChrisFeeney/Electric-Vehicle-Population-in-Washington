# Washington Electric Vehicles

## Introduction
Look into electric vehicle data in the State of Washington! This project explores EV ownership, popular makes and models, range, and more. [Data Folder](/wash_ev_sales_folder/)

SQL Queries Here:

## Background
Pushed forward by a curiosity to understand the electric vehicle market, along with an upcoming move to Seattle created this opportunity to look closer at electric vehicle sales in the State of Washington. 

Data is from a [Kaggle](https://www.kaggle.com/datasets/utkarshx27/electric-vehicle-population-data) data set.

## The Questions I Set Out to Answer
1. Which cities in Washington have the highest EV ownership? Which cities have the highest plug-in hybrid ownership?
2. What are the most popular makes of EVs owned in Washington? What are the most popular specific models of EVs owned in Washington?
What about Seattle?
3. Based upon model year what are the top 5 most popular makes each year?
4. Looking at strictly fully electric vehicles, what is the distribution of the ranges.

# Tools I Used
In this exploration of the Washington EV market I used:

- **SQL:** How I created the queries to analyze the dataset.

- **PostgreSQL:** My database management system of choice that is ideal to hold the EV dataset.

- **PowerBI:** The visualization software I chose to create graphs and dashboards of the data. [PowerBI Dashboard]()

- **Git & GitHub:** Which allow me to share my SQL scripts and analysis of the data.

# The Analysis
Every query was scripted inorder to investigate a specific question surrounding the electric car market in Washington.

Here is my approach:

## 1.  EV Ownership Numbers
In order to find which cities had the highest number of EVs and Plug-In Hybrids respectively, I wrote two queries. These queries returned a count of instances where the type of car was an EV or Plug-In Hybrid. 

```sql
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
```

```sql
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
```
Breakdown of the results:

- **Does Not Follow Population:**
The city with the most EVs and Plug-In Hybrids is unsurprisingly Seattle. This is to be expected as it is the most populated city in the State by a wide margin. However, after Bellevue in the second spot, Redmond, Bothell, and Sammamish were the 3,4, and 5 placed cities for amount of EVs. This is particualry interesting as those cities are the 17th, 21st, and 26th most populated cities. Plug-In Hybrids followed much of the same story as Tukwila the 72nd most populated city came in second place.

![EVS Per City](wash_ev_sales_folder\assets\Evs_per_city.png)

*This is a screenshot of the resulting table of EVs per city*

## 2. Makes and Models
Diving deeper, I looked at which EV manufacturer and individual model of EV was the most widespread and popular. In order to parse this data, two queries similar to the ones before were written specifically looking at EVs only.

```sql
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
```

```sql
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
```
Breakdown of the results:

- **Tesla Dominance:** 
Tesla's were the most popular EV by a clear margin. Their 79,659 occurences is nearly half of all records and more than 65,000 more than the number 2 Nissian. The model side told the same story. Four of the top six most popular models were Teslas with the Model Y and Model 3 combining for over 65,000 records.

- **Nissian:**
Nissian was the only maker appart from Tesla to reach the ten thousands, which is even more impressive considering that over 95% of their cap is in one car the Leaf. 

![Most Popular EVs](wash_ev_sales_folder\assets\most_popular_ev.png)
*This a bar graph showing the most popular EV models in the State of Washington. This graph was created in PowerBI.*
## 3. Most Popular Makes Per Year
We saw which manufacture was the most popular overall, but how about per model year. To create this query, two CTEs were used back to back in order to create a rank partitioned by year. All in the goal of returning a ranking of amount of cars per brand per year.

```sql
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
```
Breakdown of the results:

- **Same Story:** 
We see that as expected Tesla has the most popular model's from 2016-2023 as well as 2014. This makes sense as they are the most popular manufacturer overall. 

*Important to note that this query only looks at model year and not purchase year*

- **Anomolies:** 
In the years where a Tesla model wasn't the most popular, Nissian took that spot. This follows the pattern esstablished before where Nissian was second in all categories following Tesla. It is worth noting that Nissian hasn't been in the top 5 since 2022. However, in 2024 neither Tesla nor Nissian was in the top spot, it was instead BMW. This is likely due to only data from the beginning of the year being available, but it is an intereting revelation to keep an eye on.

![EV Makes Year](wash_ev_sales_folder\assets\EV_Makes.png)
*This a screenshot of the most popular EV makes per year from 2022-2024.*

## 4. Distribution of EV Range
Perhaps the most important aspect of an electric vehicle is the battery and range it has. This query was created with the purpose of looking at how many EVs fit within different buckets of range using a case statement. 

*Many records did not have a range value and was inserted as 0, so those were filted out*

```sql
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
```
Breakdown of the results:

- **Over 200:** 
Nearly 70% of all the EVs in the State have a range of over 200 miles. With nearly half of all EVs within the 200-249 mile bin. This indicates that the majority of EVs sold are within this range which is good since the more miles the better.

- **Less Than 100:** 
One surprising development is that the second most populace bin is within the 50-99 miles. To learn why this may be is outside of the scope of this data, but it can be inferred that this is due to the Nissian Leaf being the third most popular EV and it being one of the oldest. Leading to a smaller battery.

![Cars Per Range](wash_ev_sales_folder\assets\cars_per_range.png)
*This is a donut chart showcasing the distribution of EVs when it comes to range. This chart was created in PowerBI.*

# What I Learned
Throughout this exploration of the EV data I was able to progress my SQL quering skills:

- **Window Functions:** 
I was able to implement very functional and useful window functions within SQL. This included row numbers, dense ranks, partitions, etc. These were functions that up to this point I did not see a big use case but now I am much more proficient. 

- **Data Aggregation:**
My familiarity and command over aggrigation functions such as Group By, Order By, Where have only gotten stronger, and I feel very comfotable using them now.

- **Real World Application:**
I have gotten a taste of getting questions needing to be solved, finding the data, and then analyzing. These are all real world steps that happen daily for a data analyst.

# Conclusion

## Insights
General analysis:

- **Tesla:**
Tesla was the most popular EV maker as well as having four of the six most popular models. They are essentially half of the entire EV market in Washington, and this data would look completely different without them. They also have the most popular car model per year for seven straight years from 2016-2023.

- **Population Not Important ?:**
After Seattle, the spread of both EVs and Plug-In Hybrids did not follow the population trend. Some of the most populated cities had low amounts of ownership, where as smaller cities such as Bothell for EVs and Tukwilla for Plug-Ins had some of the highest ownership.

- **Range:**
As time goes on and battery technology improves, we see that adoption of EVs has gotten comfortable with a range of 200-249 miles a charge. It remains to be seen if this will increase over time or this is the sweet spot.

## Closing Thoughts

This project greatly enhanced my skill and confidence when it comes to SQL quering. The analysis gathered will greatly affect my understanding of the EV market in Washington, and set me up nicely when I move there next year.
