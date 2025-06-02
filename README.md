# SQL_Layoffs
An end-to-end SQL Project using a large-scale layoffs dataset. Sanitization of dataset using ALTER, UPDATE, DELETE, DROP, etc. functions and Analysis of clean dataset using aggregate functions, GROUP BY, window functions, and subqueries.

> Learning Credits: Alex (https://github.com/AlexTheAnalyst)


## Description
This end-to-end SQL project focused on analyzing a comprehensive dataset of global layoffs starting from 2020, capturing the impact of the COVID-19 pandemic on employment trends. The project was divided into two main phases:

#### Data Sanitization:
In this phase, the raw dataset was cleaned and prepared for analysis. Key tasks included:

- Removing duplicate entries to ensure data integrity.

- Standardizing inconsistent data formats.

- Handling null and blank values appropriately.

- Dropping irrelevant columns and rows to enhance data quality and focus.

#### Exploratory Data Analysis (EDA):
The cleaned dataset was then explored using SQL to extract meaningful insights. Techniques used included:

- Aggregate functions to identify trends and totals.

- GROUP BY clauses to segment data by company, industry, country, and date.

- LIMIT clauses to focus on top occurrences.

- Window functions for ranking and running totals.

- Subqueries for layered analysis and comparison.

_**This project enhanced my ability to apply SQL in a real-world context, deepened my understanding of data handling, and strengthened my analytical skills.**_

## Sample Queries

#### Sanitizing the Dataset

Selecting Duplicate Values:

    WITH row_cte AS(
    SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
    FROM layoffs_staging
    )
    SELECT * FROM row_cte
    WHERE row_num > 1;

#### Analyzing the Dataset

Sort Top-5 Companies by Total Layoffs for each Year

    WITH year_layoff (company, `year`, total_layoff) AS(
    	SELECT company, YEAR(`date`),
    	SUM(total_laid_off)
    	FROM layoffs_staging2
    	GROUP BY company, YEAR(`date`)
    ),
    company_rank AS(
    	SELECT *,
    	DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoff DESC) AS ranking
    	FROM year_layoff
        WHERE year IS NOT NULL
    )
    SELECT * FROM company_rank
    WHERE ranking <= 5;


