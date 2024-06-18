-- Exploratory Data Analysis
-- 1)
SELECT MAX(total_laid_off), MAX(percentage_laid_off) 
FROM layoffs_staging;

-- 2)
SELECT industry, SUM(total_laid_off) 
FROM layoffs_staging
GROUP BY industry
ORDER BY 2 DESC
LIMIT 3;

-- 3)
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging
GROUP BY company 
HAVING SUM(total_laid_off) >= 10000
ORDER BY 2 DESC;

-- 4)
SELECT DATE_FORMAT(`date`, '%M') AS `Month`,
		SUM(total_laid_off) AS total_Laid_off  
FROM layoffs_staging
GROUP BY `Month`
ORDER BY 2 DESC;

-- 5)
SELECT company, COUNT(DISTINCT YEAR(`date`)) AS years_with_layoffs
FROM  layoffs_staging
GROUP BY company
HAVING COUNT(DISTINCT YEAR(`date`)) > 2
ORDER BY years_with_layoffs DESC;

-- 6)
SELECT industry, AVG(total_layoffs) AS avg_layoffs_per_company
FROM (SELECT industry, company, COUNT(*) AS total_layoffs
    FROM layoffs_staging
    GROUP BY industry, company
) AS industry_layoffs
GROUP BY industry
ORDER BY avg_layoffs_per_company DESC
LIMIT 5;

-- 7)
SELECT YEAR(`date`) AS `year`, SUM(total_laid_off)
FROM layoffs_staging
WHERE `date` >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
GROUP BY 1
ORDER BY 2 desc;

-- 8)
WITH Rolling_Total AS
(
SELECT SUBSTR(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging
WHERE SUBSTR(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1
)
SELECT `Month`,TOTAL_OFF, SUM(total_off) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;

-- 9)
WITH company_year (company, years, total_laid_off) AS
(
SELECT company,YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging
GROUP BY company, YEAR(`date`)
),Company_Year_Rank AS 
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE `years` IS NOT NULL
ORDER BY Ranking
)
SELECT * 
FROM Company_year_rank
WHERE ranking <= 5;


-- 10)
WITH layoff_dates AS (
    SELECT DATE_FORMAT(`date`,'%M') AS `Month`,company, `date`,
	LEAD(`date`) OVER (PARTITION BY company ORDER BY `date`) AS next_layoff_date
    FROM layoffs_staging
)
SELECT `Month`,company,
    AVG(TIMESTAMPDIFF(MONTH, `date`, next_layoff_date)) AS avg_layoff_duration_months
FROM layoff_dates
WHERE next_layoff_date IS NOT NULL
GROUP BY company,`Month`
ORDER BY avg_layoff_duration_months DESC
LIMIT 6;