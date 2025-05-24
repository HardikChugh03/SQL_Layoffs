	
    -- -- -- -- -- -- -- -- -- -- -		A N A L Y Z I N G    L A Y O F F S    D A T A S E T	 - -- -- -- -- -- -- -- -- -- -- 


-- 1. find total layoffs from each month

SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

	-- ----------------------------------------------------------------------- --


-- 2. find total layoffs till each month i.e. total layoffs as a rolling total till that month

WITH rolling_total AS(
	SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS laid_off
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `month`
	ORDER BY 1
)
SELECT `month`, laid_off,
SUM(laid_off) OVER(ORDER BY `month`) AS total_layoffs
FROM rolling_total;

	-- ----------------------------------------------------------------------- --
    

-- 3. find total laid off by each company in each month that was a layoff month for that company
SELECT company, SUBSTRING(`date`, 1, 7) AS `month`,
SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
GROUP BY company, `month`
ORDER BY company, `month`;

	-- ----------------------------------------------------------------------- --
    
    
-- sort 5 companies by total layoffs for each year

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



