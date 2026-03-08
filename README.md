# 📊 YouTube Agency Business Analytics (Advanced SQL)

## 📝 Project Overview
This repository contains a suite of advanced PostgreSQL queries designed to extract actionable business intelligence for a YouTube creator agency. The queries analyze a clean dataset of creator finances (`creator_finances`) to answer complex, real-world questions about audience valuation, brand sponsorship ROI, and month-over-month channel growth.

This project demonstrates the ability to translate ambiguous business requirements into structured, production-ready SQL.

## 🛠️ Tech Stack & Skills Demonstrated
* **Database:** PostgreSQL
* **Core SQL Concepts:** 
  * Common Table Expressions (CTEs)
  * Window Functions (`LAG()`)
  * Advanced Aggregations & Math (RPM Calculations)
  * Filtering Grouped Data (`HAVING`)
  * Date/Time Extraction (`EXTRACT()`)
  * Data Type Casting & String Concatenation (`::NUMERIC`, `||`)

## 📈 The Business Logic (`agency_analytics.sql`)

### 1. The Audience Valuation (RPM Calculation)
**The Problem:** High views don't always equate to high revenue. The agency needs to know which geographic audiences are the most profitable.
**The SQL Solution:** Calculates the true Revenue Per Mille (RPM) for different global audiences by aggregating total views and AdSense revenue, safely handling integer division and casting to rank the most lucrative viewer demographics.

### 2. The Sponsor ROI Audit
**The Problem:** To negotiate better rates, the agency needs to identify its highest-paying, *recurring* brand sponsors.
**The SQL Solution:** Uses aggregation to find the average agency earnings per brand, implementing the `HAVING` clause to filter out skewed data from one-off deals (brands with 3 or fewer sponsored videos).

### 3. The Viral Momentum Tracker (MoM Growth)
**The Problem:** Leadership requires a month-over-month revenue comparison to track channel momentum.
**The SQL Solution:** Utilizes a CTE to pre-aggregate revenue by month (using `EXTRACT()`). The main query then implements the `LAG()` window function to place previous month revenue alongside current month revenue, calculating the exact percentage growth while safely handling potential division-by-zero errors.

## 🚀 Usage
The queries in this repository are written for PostgreSQL. To test the logic, simply execute the code blocks inside `agency_analytics.sql` against any SQL IDE (like pgAdmin or DBeaver) connected to the `creator_finances` table.
