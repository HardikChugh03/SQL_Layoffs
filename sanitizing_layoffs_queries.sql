	
    -- -- -- -- -- -- -- -- -- -- -		S A N I T I Z I N G    L A Y O F F S    D A T A S E T	 - -- -- -- -- -- -- -- -- -- -- 


-- STEPS FOR SANATAZING THE DATA

-- remove duplicates
-- standardize dataset
-- handeling null or blank values
-- remove unnecessary columns or rows


-- creating duplicate dataset, raw dataset might me required afterwards

CREATE TABLE layoffs_staging
LIKE layoffs_table;

INSERT layoffs_staging
SELECT * FROM layoffs_table;

SELECT * FROM layoffs_staging;

	-- ----------------------------------------------------------------------- --


-- 1. remove duplicates

-- creating a column 'row_num' which contain value > 1 only if there are duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- selecting duplicate values
WITH row_cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT * FROM row_cte
WHERE row_num > 1;

-- can't temove the duplicate from a cte, therefore create a new table with 'row_num' as a seperate column
-- right click on the layoffs_staging in the schemas tab and select 'copy to clipcoard', then select 'create statement' and then paste in the query, to get the following query
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM  layoffs_staging2
WHERE row_num > 1;

SELECT * FROM layoffs_staging2;

	-- ----------------------------------------------------------------------- --
    

-- 2. standardize dataset

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT * FROM layoffs_staging2;

SELECT DISTINCT industry FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry FROM layoffs_staging2
ORDER BY 1;


SELECT DISTINCT country FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

UPDATE layoffs_staging2
SET country = "United States"
WHERE country LIKE 'United States%';


SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
    
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;

	-- ----------------------------------------------------------------------- --


-- 3. handeling null or blank values

SELECT * FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- selecting each company which has null or blank industry value and populating it with same company industry value from other rows data

SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry =  'Travel'
WHERE company = 'Airbnb';


SELECT * FROM layoffs_staging2
WHERE company = "Bally's Interactive";


SELECT * FROM layoffs_staging2
WHERE company = "Carvana";

UPDATE layoffs_staging2
SET industry =  'Transportation'
WHERE company = 'Carvana';


SELECT * FROM layoffs_staging2
WHERE company = "Juul";

UPDATE layoffs_staging2
SET industry =  "Consumer"
WHERE company = "Juul";

	-- ----------------------------------------------------------------------- --


-- 4. remove unnecessary columns or rows

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL OR total_laid_off = ''
AND percentage_laid_off IS NULL OR percentage_laid_off = '';

SELECT * FROM layoffs_staging2;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
 
