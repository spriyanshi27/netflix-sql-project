# Netflix Data Cleaning and Analysis Project (ELT)

This project walks through a complete ELT pipeline using **Python**, **SQLAlchemy**, and **SQL Server** to clean and analyze Netflix titles data.

---

## What This Project Covers

- Create a base table in SQL Server
- Load the Netflix dataset from CSV using **Pandas**
- Insert the data into SQL Server using **SQLAlchemy**
- Clean and transform data using SQL (CTEs, joins, window functions)
- Normalize columns like `cast`, `listed_in`, `country`, and `director`
- Perform SQL-based analysis to extract insights

---

## Tech Stack

- **Python** – for data loading and preprocessing
- **SQLAlchemy** – connects Python to SQL Server
- **SQL Server** – stores and transforms the data
- **T-SQL** – used for cleaning and analysis

---

## Steps

### 1. Create Table
Run `netflix_raw.sql` to create the `netflix_raw` table in SQL Server.

### 2. Load Data
Use `netflix_etl.py` to:
- Read `netflix_titles.csv` with `pandas`
- Load data into SQL Server using `df.to_sql()`

### 3. Clean & Transform
In `netflix_sql_project.sql`:
- Remove duplicates using `ROW_NUMBER() OVER (...)`
- Normalize multi-value fields with `STRING_SPLIT()` + `CROSS APPLY`
- Handle missing values (e.g., infer `country` from `director`)
- Clean formatting as needed

### 4. Analyze the Data
Use SQL to answer:
- Which country produces the most comedy titles?
- Which director released the most content each year?
- What’s the average duration per genre?
- Which directors made both horror and comedy?

---

## Sample Insights

- Top countries by comedy movie count  
- Most active directors per year  
- Average duration of movies by genre  
- Directors who created both horror and comedy titles  

---

## Files Included

| File | Description |
|------|-------------|
| `netflix_titles.csv` | Raw dataset |
| `netflix_raw.sql` | Creates the base SQL table |
| `netflix_etl.py` | Loads CSV into SQL Server |
| `netflix_sql_project.sql` | Contains SQL logic for cleaning and analysis |
| `README.md` | Project overview and setup instructions |

---

## Prerequisites

- Python 3.x  
- `pandas`, `sqlalchemy`  
- Microsoft SQL Server (any edition)  
- ODBC Driver 17 for SQL Server  

---

## Dataset Source

[Netflix Titles – Kaggle](https://www.kaggle.com/datasets/shivamb/netflix-shows)
