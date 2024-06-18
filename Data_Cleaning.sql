-- Data Cleaning

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Any Colunms




-- 1. Remove Duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;


WITH duplicate_cte AS (

SELECT *, ROW_NUMBER() OVER(PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

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
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY
company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;


SELECT * FROM layoffs_staging2
WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;




-- 2. Standardize the Data

SELECT * FROM layoffs_staging2;

-- ) Company

SELECT company, TRIM(company) FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


-- ) Industry

SELECT DISTINCT(industry) FROM layoffs_staging2
WHERE industry LIKE "crypto%";

UPDATE layoffs_staging2 
SET industry = "crypto"
WHERE industry LIKE "crypto%";

-- ) Country

SELECT DISTINCT(country) FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
WHERE country LIKE "united states%";

UPDATE layoffs_staging2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE "united states%";


-- ) Date

SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y')  FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY `date` DATE;




-- 3. Null Values or Blank Values


UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT DISTINCT industry FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT * FROM layoffs_staging2
WHERE company = "airbnb";

SELECT * FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;



-- 4. Remove Any Colunms

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP row_num;

