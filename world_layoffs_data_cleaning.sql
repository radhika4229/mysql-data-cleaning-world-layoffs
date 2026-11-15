-- ============================================================
-- WORLD LAYOFFS - DATA CLEANING PROJECT
-- ============================================================

-- 1. View raw data
SELECT *
FROM layoffs;


-- ============================================================
-- 2. CREATE STAGING TABLE
-- ============================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;


-- ============================================================
-- 3. CHECK FOR DUPLICATES
-- ============================================================

SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
) AS duplicates
WHERE row_num > 1;


-- ============================================================
-- 4. CREATE SECOND STAGING TABLE WITH ROW NUMBER
-- ============================================================

CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);

INSERT INTO layoffs_staging2 (
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    row_num
)
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY
            company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions
    ) AS row_num
FROM layoffs_staging;


-- Check duplicate rows
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- ============================================================
-- 5. REMOVE DUPLICATES
-- ============================================================

DELETE FROM layoffs_staging2
WHERE row_num >= 2;


-- ============================================================
-- 6. STANDARDIZE INDUSTRY
-- ============================================================

-- Check unique industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;


-- Check missing/blank industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = ''
ORDER BY industry;


-- Convert blank values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- Fill missing industry values using another row
-- from the same company where industry is known
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Check remaining NULL industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL;


-- Standardize Crypto industry names
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');


-- Verify industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;


-- ============================================================
-- 7. STANDARDIZE COUNTRY
-- ============================================================

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;


-- Remove trailing periods
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Verify
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;


-- ============================================================
-- 8. STANDARDIZE DATE
-- ============================================================

-- Convert text date into MySQL date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- Change column datatype from TEXT to DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Verify
SELECT *
FROM layoffs_staging2;


-- ============================================================
-- 9. HANDLE NULL VALUES
-- ============================================================

-- Check rows with missing total layoffs
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


-- Check rows where both key layoff measures are missing
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Remove rows where both values are missing
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Verify
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- ============================================================
-- 10. REMOVE TEMPORARY COLUMN
-- ============================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- ============================================================
-- 11. FINAL VALIDATION
-- ============================================================

-- Total rows
SELECT COUNT(*) AS total_rows
FROM layoffs_staging2;


-- Check for remaining exact duplicates
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    COUNT(*) AS duplicate_count
FROM layoffs_staging2
GROUP BY
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions
HAVING COUNT(*) > 1;


-- Check NULL values
SELECT
    COUNT(*) AS total_rows,
    SUM(company IS NULL) AS null_company,
    SUM(industry IS NULL) AS null_industry,
    SUM(total_laid_off IS NULL) AS null_total_laid_off,
    SUM(percentage_laid_off IS NULL) AS null_percentage,
    SUM(`date` IS NULL) AS null_date,
    SUM(stage IS NULL) AS null_stage,
    SUM(country IS NULL) AS null_country,
    SUM(funds_raised_millions IS NULL) AS null_funds
FROM layoffs_staging2;


-- Check column data types
DESCRIBE layoffs_staging2;