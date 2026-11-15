# SunVolt Solar Customer Analytics: SQL & Power BI Project

## Project Overview
This repository contains an end-to-end data analysis and business intelligence project for **SunVolt**, a residential solar energy provider. The project demonstrates database schema creation, data ingestion, exploratory SQL querying, data quality auditing, and interactive dashboard reporting to evaluate customer demographics and solar system conversion rates.

---

## Repository Structure
* **`SunVolt_Analysis.sql`** *(SQL Script)*: A comprehensive T-SQL script divided into five sections covering DDL/DML operations, filtering, aggregations, relational joins, subqueries, and data integrity checks.
* **`SunVolt_Dashboard.pbix`** *(Power BI Report)*: A multi-page interactive Power BI report built on the `SunVolt` data model, featuring custom themes (`Fluent2`) and visual breakdowns of customer segments and purchasing behavior.

---

## SQL Script Breakdown (`SunVolt_Analysis.sql`)
The SQL script is organized into five progressive sections designed for **Microsoft SQL Server (T-SQL)**:

### **Section A: Database & Table Creation**
* Creates the `SunVolt` database and defines the core `dbo.customers` fact/dimension table alongside a `dbo.distance_bands` lookup table for installer proximity sorting.
* Handles data ingestion from a staging table (`SunVolt_Solar_Customer_temp`), maps columns, cleans up temporary objects, and documents the differences between `DELETE`, `TRUNCATE`, and `DROP`.

### **Section B: Selecting, Filtering & Aliases**
* Extracts targeted customer cohorts using `WHERE`, `DISTINCT`, `BETWEEN`, `LIKE`, and compound boolean logic (`AND`/`OR`).
* Focuses on regional age demographics, income brackets, homeowner education levels, and household asset profiles.

### **Section C: Aggregation & Grouping**
* Calculates overall and segmented **Conversion Percentages** (`purchases / total customers`) across regions, education levels, age groups, and genders.
* Uses `GROUP BY` and `HAVING` clauses to filter out low-volume cohorts (`COUNT(*) >= 100` and `purchases > 50`).

### **Section D: Joins & Subqueries**
* **Joins**: Uses `INNER JOIN` and `LEFT JOIN` to link `customers` with `distance_bands`, ensuring logical ordering by `installer_distance_order` rather than alphabetical string sorting.
* **Subqueries**: Implements scalar subqueries to identify above-average income earners (`533` rows) and correlated subqueries to isolate customers in high-performing regions (`> 45%` conversion rate).

### **Section E: Data Quality & Conditional Logic**
* Dynamically segments customers into custom age brackets (`Under 40`, `40-59`, `60+`) using `CASE` statements.
* Performs data hygiene and validation checks, including duplicate `customer_id` detection, flag consistency auditing (`IS DISTINCT FROM`), and unique buyer counts.

---

##  Power BI Report (`SunVolt_Dashboard.pbix`)
The accompanying `.pbix` file connects to the `SunVolt` dataset to provide visual decision-support across **2 report pages** and **12 interactive visuals**. 
* **Key Focus Areas**: Customer demographic distribution, regional conversion performance, income vs. purchase propensity, and installer distance impact.

---

##  How to Run & Review

### **1. Running the SQL Script**
1. Open **SQL Server Management Studio (SSMS)** or **Azure Data Studio**.
2. Execute **Section A (A1–A3)** to create the `SunVolt` database and tables.
3. Import the raw `SunVolt_Solar_Customer` Excel/CSV dataset into `SunVolt.dbo.SunVolt_Solar_Customer_temp` via the SQL Server Import Wizard, then run **A4** to populate `dbo.customers`.
4. Execute **Sections B through E** sequentially to inspect the query outputs.

### **2. Viewing the Power BI Report**
1. Ensure **Microsoft Power BI Desktop** is installed.
2. Open the `.pbix` file directly from the repository. *(Note: All data is embedded within the report's internal `DataModel`, so no external database connection is required to interact with the visuals).*
