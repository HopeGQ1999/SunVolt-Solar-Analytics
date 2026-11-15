--Section A: Database and Table Creation

--A1:

CREATE database SunVolt;

--A2:

CREATE TABLE SunVolt.dbo.customers(
	customer_id INT,
	marital_status VARCHAR (50),
	gender VARCHAR (50),
	annual_income INT,
	household_dependents INT,
	education_level VARCHAR (50),
	occupation VARCHAR (50),
	homeowner_status VARCHAR (50),
	vehicles_owned INT,
	distance_band VARCHAR (50),
	region VARCHAR (50),
	age INT,
	purchased_solar_system VARCHAR (50),
	purchase_flag INT,
	age_group VARCHAR (50),
	income_band VARCHAR (50),
	installer_distance_order INT,
);

SELECT * FROM SunVolt.dbo.customers;
GO


--A3:


IF OBJECT_ID('SunVolt.dbo.distance_bands', 'U') IS NOT NULL
    DROP TABLE SunVolt.dbo.distance_bands;
GO

CREATE TABLE SunVolt.dbo.distance_bands (
    distance_band VARCHAR(50),
    installer_distance_order INT
);
GO

INSERT INTO SunVolt.dbo.distance_bands (distance_band, installer_distance_order)
VALUES
    ('0-1 km', 1),
    ('1-2 km', 2),
    ('2-5 km', 3),
    ('5-10 km', 4),
    ('10+ km', 5);
GO

SELECT * FROM SunVolt.dbo.distance_bands;
GO



--A4:

IMPORT

-- 1. Insert and map the data from the temporary table to your existing table
INSERT INTO SunVolt.dbo.customers (
    customer_id,
    marital_status,
    gender,
    annual_income,
    household_dependents,
    education_level,
    occupation,
    homeowner_status,
    vehicles_owned,
    distance_band,            -- <--- Your target column
    region,
    age,
    purchased_solar_system,
    purchase_flag,
    age_group,
    income_band,
    installer_distance_order
)
SELECT 
    [Customer_id],
    [Marital_Status],
    [Gender],
    [Annual_Income],
    [Household_Dependents],
    [Education_Level],
    [Occupation],
    [Homeowner_Status],
    [Vehicles_Owned],
    [Distance_from_Nearest_Installer], -- <--- Maps Excel column to distance_band
    [Region],
    [Age],
    [Purchased_Solar_System],
    [Purchase_Flag],
    [Age_Group],
    [Income_Band],
    Installer_Distance_Order
    -- [Installer Distance Order] is omitted here, so it is completely ignored
FROM SunVolt.dbo.SunVolt_Solar_Customer_temp;

-- 2. Drop the temporary staging table to keep your database clean
DROP TABLE SunVolt.dbo.SunVolt_Solar_Customer_temp;

-- 3. Return the final total row count of the customers table
SELECT COUNT(*) AS total_customers 
FROM SunVolt.dbo.customers;


SELECT * FROM SunVolt.dbo.SunVolt_Solar_Customer_temp;
GO

--A5:

-- DELETE: removes a specific or specific rows from a table.
-- TRUNCATE: removes all rows from a table
-- DROP: removes the entire table, including data and structure.

--Section B: Selecting, Filtering and Aliases

--B1:

SELECT customer_id,
	age,
	annual_income AS income
FROM SunVolt.dbo.customers
WHERE region = 'Europe' AND
	age >= 40
;


--B2:

SELECT DISTINCT occupation
FROM SunVolt.dbo.customers
ORDER BY occupation;

--B3:

SELECT customer_id,
	annual_income AS income
FROM SunVolt.dbo.customers
WHERE annual_income BETWEEN 30000 AND 70000
ORDER BY income DESC;

--B4:

SELECT COUNT(*) AS total_rows,
	COUNT(DISTINCT (customer_id)) AS unique_customers
FROM SunVolt.dbo.customers;


--B5:

SELECT customer_id,
	education_level,
	homeowner_status
FROM SunVolt.dbo.customers
WHERE (education_level = 'Bachelors' OR education_level = 'Graduate Degree') 
  AND homeowner_status = 'Yes'
;


--B6:

SELECT customer_id,
	occupation
FROM SunVolt.dbo.customers
WHERE occupation LIKE 'Man%'
;


--B7:

SELECT customer_id,
	marital_status,
	vehicles_owned,
	household_dependents
FROM SunVolt.dbo.customers
WHERE marital_status = 'Single' AND
	(vehicles_owned >= 2  OR
	household_dependents >= 3)
;


--Section C: Aggregation and Grouping

--C1:

SELECT
	COUNT(*) AS customers,
	SUM(purchase_flag) AS purchases,
	((SUM(purchase_flag) * 1.0) / COUNT(*)) * 100 AS conversion_pct
FROM SunVolt.dbo.customers;


--C2:

SELECT region,
	COUNT(*) AS customers,
	SUM(purchase_flag) AS purchases,
	((SUM(purchase_flag) * 1.0) / COUNT(*)) * 100 AS conversion_pct
FROM SunVolt.dbo.customers
GROUP BY region
ORDER BY region DESC;


--C3:

SELECT education_level,
	COUNT(*) AS customers,
	ROUND(AVG(annual_income), 0) AS avg_income
FROM SunVolt.dbo.customers
GROUP BY education_level
HAVING COUNT(*) >= 100
ORDER BY avg_income DESC
;


--C4:

SELECT age_group,
	COUNT(*) AS customers,
	SUM(CAST(purchase_flag AS INT)) AS purchases
FROM SunVolt.dbo.customers
GROUP BY age_group
HAVING SUM(CAST(purchase_flag AS INT)) > 50
ORDER BY purchases DESC
;


--C5:

SELECT gender,
	MIN(age) AS youngest,
	MAX(age) AS oldest,
	ROUND(AVG(annual_income), 0) AS avg_income
FROM SunVolt.dbo.customers
GROUP BY gender;


--Section D: Joins and Subqueries

--D1:

SELECT a.distance_band,
				b.installer_distance_order,
				COUNT(*) AS customers,
				SUM(CAST(a.purchase_flag AS INT)) AS purchases
FROM SunVolt.dbo.customers a

INNER JOIN SunVolt.dbo.distance_bands b
					ON a.distance_band = b.distance_band

GROUP BY 
    a.distance_band,
    b.installer_distance_order
ORDER BY 
    b.installer_distance_order ASC;
;


--D2:
---- Number of rows returned: 533

SELECT customer_id,
	annual_income
FROM SunVolt.dbo.customers
WHERE annual_income > (
			SELECT AVG(annual_income)
			FROM SunVolt.dbo.customers
)
;


--D3:

SELECT customer_id,
	region,
	purchase_flag

FROM SunVolt.dbo.customers AS outer_cust

WHERE (

    SELECT AVG(CAST(inner_cust.purchase_flag AS FLOAT)) * 100
    FROM SunVolt.dbo.customers AS inner_cust
    WHERE inner_cust.region = outer_cust.region
) > 45
;

--D4:

SELECT
    db.distance_band,
    COUNT(c.customer_id) AS customers

FROM SunVolt.dbo.distance_bands AS db

LEFT JOIN SunVolt.dbo.customers  AS c 
	ON db.distance_band = c.distance_band
GROUP BY
    db.distance_band,
    db.installer_distance_order
ORDER BY
    db.installer_distance_order
    ;



--Section E: Data Quality and CASE

--E1:

SELECT 
	-- Conditional column comes first:
	CASE 
		WHEN age < 40 THEN 'Under 40'
		WHEN age BETWEEN 40 AND 59 THEN '40-59'
		ELSE '60+'
	END AS age_segment,

	-- The rest of the columns follow:
	COUNT(*) AS customers,
	SUM(purchase_flag) AS purchases,
	((SUM(purchase_flag) * 1.0) / COUNT(*)) * 100 AS conversion_pct
FROM SunVolt.dbo.customers
GROUP BY 
					CASE 
		WHEN age < 40 THEN 'Under 40'
		WHEN age BETWEEN 40 AND 59 THEN '40-59'
		ELSE '60+' 
	END;



--E2: Finding Customers Duplicates 

SELECT customer_id,
	COUNT(customer_id) AS customers

FROM SunVolt.dbo.customers
GROUP BY customer_id
HAVING customer_id > 1;

--E3: Finding Mismatches

SELECT COUNT(*) AS mismatches
FROM SunVolt.dbo.customers
WHERE CASE 
        WHEN purchased_solar_system = 'Yes' THEN 1
        WHEN purchased_solar_system = 'No' THEN 0
      END IS DISTINCT FROM purchase_flag
;

--E4: 

SELECT COUNT(DISTINCT customer_id) AS unique_buyers
FROM SunVolt.dbo.customers
WHERE purchase_flag = 1
;


SELECT @@SERVERNAME;
