-- Data cleaning is basically where you get your data to a more useable format
-- till you can fix a lot of issues in the raw dta that when you start creating visualization or start using it in yourproduct
-- that the data is actually useful and is not a lot issue with it.

-- Creating a database and importing data
-- Ceate database>> Create a new schema 'world_layoffs'>> Click apply>> Right click on table onthe schemas pane
-- Click on import table wizard>> Browse and select your data
-- You can change the data type cos MYSQL gives columns data type by default
-- view the table

SELECT *
FROM layoffs;

-- STEPS FORDATA CLEANNING
-- 1. Remove duplicates
-- 2. Standardized the data
-- 3. Nulls and Blank values
-- 4. Remove colums or rows.

-- Its best practice not to work directly on raw data but instead create duplicates s as not to lose data after alteration
-- thus create duplicate table staging alterations

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- REMOVING DUPLICATE
-- this is easily done using row numbers, thus we create row nubers for the data

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- confirm each row if they are actually duplicate

SELECT *
FROM layoffs_staging
WHERE company = 'Hibob';

-- To delete duplicatein MySQL, create a staging 2 database i.e a table having the row column this can also be done by
-- Click in Layoffs_staging fom the schemas pane >> click on copy to clipboard >> clickon th create statement
-- edit the data type or add column you can actually give the table a name of your choice.

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
  `row_num` INT 	 #here we added the row column
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging);

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- STANDARDIZING THE DATA is finding issues in your data and fixing it. CHeck for each column, hint use distinct to check each column

SELECT *
FROM layoffs_staging2;

SELECT DISTINCT company
FROM layoffs_staging2;

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

SELECT DISTINCT location
FROM layoffs_staging2;

SELECT location, TRIM(TRAILING '¶' FROM 'MalmÃ¶')
FROM layoffs_staging2
WHERE location = 'MalmÃ¶';

UPDATE layoffs_staging2
SET location = TRIM(TRAILING '¶' FROM 'MalmÃ¶')
WHERE location = 'MalmÃ¶';

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Changing the date column datatype to date-datatype
SELECT `date`,STR_TO_DATE(`date`, '%m/%d/%Y') AS `date`    # in the bracket the first parameteris the column name second is the date format
FROM layoffs_staging2;										# use back_tick cos date is a keyword

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2		# The date column data type would be modified after setting the dte format
MODIFY COLUMN `date` DATE;			# use ALTER statement to change the column data type

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)		#Trailing is an advance trim function to trim any specified text after needed word in a column
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- DEALING WITH NULLS AND BLANK VALUES; Try to populate the blank or null fields where possible

SELECT DISTINCT INDUSTRY
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL;

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE t1.industry IS NULL;

-- WE have to translate this to an update statement

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	on t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;

-- DELETING COLUMNS AND ROWS; Be sure the rows or columns are not needed for your analysis
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;




