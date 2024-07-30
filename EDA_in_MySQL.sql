-- Exploratory Data Analysis (EDA) :
-- After cleaning your data, you are set to explore the data to find insights from the data
-- Usually, you may have some ideas of what you are looking for, sometimes as you explore your data you may still do some cleaning in the process.

SELECT *
FROM layoffs_staging2;

-- Month each year with their max, min and avg total laid off
SELECT SUBSTRING(`date`,1,7) AS `month`, MAX(total_laid_off),MIN(total_laid_off), AVG(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY `month`;

SELECT percentage_laid_off, funds_raised_millions
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL AND percentage_laid_off IS NOT NULL
ORDER BY funds_raised_millions;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY country;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY industry;

SELECT YEAR(`date`) AS years, company,SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`), company
ORDER BY YEAR(`date`) ASC;

SELECT YEAR(`date`) AS years, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL AND YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) ASC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY stage DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Progression of layoffs
-- Rolling tottal 

SELECT SUBSTRING(`date`,1,7) AS `month`, SUM( total_laid_off ) AS total_offs
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY`month`
ORDER BY `month` ASC;

WITH Rolling_Total AS
(SELECT SUBSTRING(`date`,1,7) AS `month`, SUM( total_laid_off ) AS total_offs
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY`month`
ORDER BY `month` ASC)
SELECT `month`, total_offs, SUM( total_offs)
OVER(ORDER BY `month`) AS rolling_total
FROM Rolling_Total;

-- Rolling total of laid offs by company and years
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)
ORDER BY 3 ASC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

-- To rank whichyear they laid off the most employee

WITH company_years ( company, years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`))
	SELECT *, DENSE_RANK()OVER(PARTITION BY years ORDER BY total_laid_off) AS Ranking
    FROM company_years
    WHERE years IS NOT NULL
    ORDER BY Ranking ASC;
    
-- to filter the Ranking
WITH company_years ( company, years, total_laid_off) AS
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, YEAR(`date`)), company_year_rank AS
	(SELECT *, DENSE_RANK()OVER(PARTITION BY years ORDER BY total_laid_off) AS Ranking
    FROM company_years
    WHERE years IS NOT NULL
    ORDER BY Ranking ASC)
SELECT *
FROM company_year_rank
WHERE Ranking <=5;

SELECT *
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE `date` >= DATE_SUB(curdate(), interval 700 DAY);

SELECT *
FROM layoffs_staging2
WHERE `date` >= '2023-03-06'-'2023-01-01';


