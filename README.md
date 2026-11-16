# World Layoffs Data Cleaning — MySQL

## 📌 Project Overview

This project focuses on cleaning and standardizing a global layoffs dataset using MySQL.

The goal was to transform raw, inconsistent data into a cleaner and more reliable dataset that can be used for further analysis and visualization.

## 🗂️ Dataset

The dataset contains information about company layoffs, including:

- Company
- Location
- Industry
- Total employees laid off
- Percentage of workforce laid off
- Date
- Company stage
- Country
- Funds raised

## 🛠️ Tools Used

- MySQL
- MySQL Workbench
- SQL

## 🧹 Data Cleaning Process

The following steps were performed:

1. Created a staging table to preserve the original dataset.
2. Identified duplicate records using `ROW_NUMBER()` and `PARTITION BY`.
3. Removed duplicate records while keeping the first occurrence.
4. Identified and handled missing `industry` values.
5. Used a self `JOIN` to populate missing industry values where reliable information was available.
6. Standardized different Crypto industry names into a single value.
7. Cleaned inconsistent country values using `TRIM()`.
8. Converted the `date` column from text to the MySQL `DATE` datatype using `STR_TO_DATE()`.
9. Removed records where both `total_laid_off` and `percentage_laid_off` were missing.
10. Performed final data-quality validation.

## 📚 SQL Concepts Practiced

- `CREATE TABLE`
- `INSERT INTO ... SELECT`
- `SELECT DISTINCT`
- `WHERE`
- `GROUP BY`
- `HAVING`
- `ROW_NUMBER()`
- `PARTITION BY`
- `UPDATE`
- `DELETE`
- `JOIN`
- Self JOIN
- `NULL` handling
- `TRIM()`
- `STR_TO_DATE()`
- `ALTER TABLE`
- Data validation

## 🔍 Key Learning

This project helped me understand that data cleaning is not simply about removing NULLs or duplicates.

Before modifying data, I learned to:

- inspect the data,
- identify inconsistencies,
- understand why a value is missing,
- avoid making assumptions,
- apply transformations,
- and validate the cleaned result.

## 📁 Project Structure

```text
mysql-data-cleaning-world-layoffs/
│
├── README.md
│
└── sql/
    └── world_layoffs_data_cleaning.sql
```

## 🚀 Next Step

The cleaned dataset can be used for exploratory data analysis to identify trends in layoffs by:

- Company
- Industry
- Country
- Year
- Funding
- Company stage
- Total layoffs

## 📊 Dataset Source

World Layoffs dataset from Kaggle.