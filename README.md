# Walmart Sales Data Analysis — MySQL

## 📌 Project Overview

This project performs **Walmart sales data analysis using Python, Pandas, and MySQL**.

The workflow starts with loading and cleaning the Walmart sales dataset in Python, creating a derived `total` sales column, loading the cleaned data into a MySQL database, and then answering business-oriented questions using SQL.

The project focuses on practical SQL concepts such as:

* `GROUP BY`
* Aggregate functions (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`)
* `CASE` statements
* Date and time functions
* `DENSE_RANK()` window functions
* Common Table Expressions (CTEs)
* Subqueries
* Year-over-year revenue comparison

The accompanying notebook shows the data-loading and cleaning workflow, including duplicate and missing-value handling, conversion of `unit_price`, creation of the `total` column, and loading 9,969 cleaned records into MySQL.

---

## 🎯 Project Objectives

The main objectives are to:

1. Clean and prepare Walmart sales data.
2. Load the cleaned dataset into MySQL.
3. Analyze transactions and quantities by payment method.
4. Identify the highest-rated category for each branch.
5. Find the busiest day for each branch.
6. Identify the payment method with the highest quantity sold within each category.
7. Analyze category ratings by city.
8. Calculate total profit by category.
9. Identify the most common payment method for each branch.
10. Analyze transactions across morning, afternoon, and evening shifts.
11. Compare branch revenue across years and identify branches with the largest revenue decrease.

---

## 🛠️ Technologies Used

| Technology       | Purpose                              |
| ---------------- | ------------------------------------ |
| Python           | Data loading and preprocessing       |
| Pandas           | Data cleaning and transformation     |
| MySQL            | Data storage and SQL analysis        |
| SQLAlchemy       | Connecting Python with MySQL         |
| PyMySQL          | MySQL database adapter               |
| Jupyter Notebook | Development and analysis environment |

---

## 📂 Dataset

The project uses a Walmart sales dataset containing fields such as:

* `invoice_id`
* `Branch`
* `City`
* `category`
* `unit_price`
* `quantity`
* `date`
* `time`
* `payment_method`
* `rating`
* `profit_margin`

The notebook initially contains **10,051 rows** and **11 columns**. It identifies **51 duplicate rows** and **31 missing values** in both `unit_price` and `quantity`. After removing duplicates and rows containing missing values, the cleaned dataset contains **9,969 rows**.

The `unit_price` field is converted from a dollar-formatted string to a numeric value, and a new `total` column is calculated as:

```text
total = unit_price × quantity
```

The cleaned data is saved as `walmart_clean_data.csv` and loaded into the MySQL `walmart` table.

---

## 🔄 Data Processing Workflow

```text
Walmart Dataset
       ↓
Load using Pandas
       ↓
Check structure and statistics
       ↓
Remove duplicate records
       ↓
Check and remove missing values
       ↓
Convert unit_price to numeric
       ↓
Create total sales column
       ↓
Save cleaned CSV
       ↓
Load data into MySQL
       ↓
Run SQL business analysis
```

---

## 🗄️ Database Setup

Create the database and select it:

```sql
CREATE DATABASE walmart_db;
USE walmart_db;
```

Check the available tables:

```sql
SHOW TABLES;
```

Preview the Walmart table:

```sql
SELECT * 
FROM walmart 
LIMIT 5;
```

---

# 📊 Business Problems Solved

## Q1. Payment Method Analysis

Find the number of transactions and total quantity sold for each payment method.

```sql
SELECT 
    payment_method,
    COUNT(invoice_id) AS No_of_tanzxn,
    SUM(quantity) AS no_of_qnt
FROM walmart
GROUP BY payment_method;
```

### Business Insight

This analysis helps understand:

* Which payment methods are most frequently used.
* How many transactions are processed through each payment method.
* The quantity of products sold through each payment method.

---

## Q2. Highest-Rated Category in Each Branch

Uses `DENSE_RANK()` to identify the category with the highest average rating in every branch.

```sql
SELECT *
FROM
(
    SELECT
        Branch,
        Category,
        ROUND(AVG(rating), 2) AS AVG_rating,
        DENSE_RANK() OVER(
            PARTITION BY Branch 
            ORDER BY AVG(rating) DESC
        ) AS rank_stat
    FROM walmart
    GROUP BY Branch, Category
) AS rank_table
WHERE rank_stat = 1;
```

### SQL Concepts Used

* `AVG()`
* `ROUND()`
* `GROUP BY`
* `DENSE_RANK()`
* `PARTITION BY`
* Subquery

---

## Q3. Busiest Day for Each Branch

Determines the day of the week with the highest number of transactions for each branch.

```sql
SELECT *
FROM
(
    SELECT  
        Branch,
        DAYNAME(STR_TO_DATE(`date`, '%d/%m/%Y')) AS DAY_Name,
        COUNT(invoice_id) AS Total,
        DENSE_RANK() OVER(
            PARTITION BY Branch 
            ORDER BY COUNT(invoice_id) DESC
        ) AS Highest_tnzxn
    FROM walmart
    GROUP BY Branch, DAY_Name
) AS high
WHERE Highest_tnzxn = 1;
```

### SQL Concepts Used

* `STR_TO_DATE()`
* `DAYNAME()`
* `COUNT()`
* `DENSE_RANK()`
* `PARTITION BY`
* Subquery

---

## Q4. Highest Quantity-Selling Payment Method by Category

Identifies the payment method that accounts for the highest quantity sold within each category.

```sql
SELECT * 
FROM
(
    SELECT 
        category,
        payment_method,
        SUM(quantity) AS total_quantity,
        DENSE_RANK() OVER(
            PARTITION BY category 
            ORDER BY SUM(quantity) DESC
        ) AS ranky
    FROM walmart
    GROUP BY category, payment_method
) AS tot_rank
WHERE ranky = 1;
```

### Business Insight

This helps determine which payment method contributes the highest product quantity within each product category.

---

## Q5. Category Ratings by City

Calculates:

* Average rating
* Minimum rating
* Maximum rating

for each city and category combination.

```sql
SELECT
    city,
    category,
    ROUND(AVG(rating), 2) AS average,
    MIN(rating) AS minimum,
    MAX(rating) AS maximum
FROM walmart
GROUP BY city, category;
```

### Business Insight

This analysis helps compare customer satisfaction across different cities and product categories.

---

## Q6. Total Profit by Category

Calculates total profit using:

```text
Total Profit = Total Sales × Profit Margin
```

SQL:

```sql
SELECT 
    category,
    ROUND(SUM(total * profit_margin), 2) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;
```

### Business Insight

This identifies which product categories generate the highest total profit.

---

## Q7. Most Common Payment Method by Branch

Uses `DENSE_RANK()` to find the most frequently used payment method for every branch.

```sql
SELECT * 
FROM
(
    SELECT 
        Branch,
        payment_method,
        COUNT(payment_method) AS cnt,
        DENSE_RANK() OVER(
            PARTITION BY Branch 
            ORDER BY COUNT(payment_method) DESC
        ) AS method_rank
    FROM walmart
    GROUP BY Branch, payment_method
) AS rank_payment
WHERE method_rank = 1;
```

### Business Insight

This helps identify the preferred payment method at each branch.

---

## Q8. Sales by Time of Day

Transactions are categorized into three shifts:

* **MORNING** — before 12 PM
* **AFTERNOON** — 12 PM to 5 PM
* **EVENING** — after 5 PM

```sql
SELECT 
    CASE
        WHEN HOUR(`time`) < 12 THEN 'MORNING'
        WHEN HOUR(`time`) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        ELSE 'EVENING'
    END AS shift,
    COUNT(invoice_id) AS total_invoices
FROM walmart
GROUP BY shift;
```

### Business Insight

This analysis helps identify the busiest time of day based on the number of transactions.

---

## Q9. Branches With the Highest Revenue Decrease

Uses CTEs to calculate branch revenue for two years and then compares the previous year's revenue with the current year's revenue.

### Revenue Decrease Formula

```text
Revenue Decrease Ratio =
((Last Year Revenue - Current Year Revenue) / Last Year Revenue) × 100
```

SQL:

```sql
WITH revenue_2022 AS
(
    SELECT 
        Branch,
        ROUND(SUM(total), 2) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%Y')) = 2022
    GROUP BY Branch
),
revenue_2023 AS
(
    SELECT 
        Branch,
        ROUND(SUM(total), 2) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%Y')) = 2023
    GROUP BY Branch
)
SELECT
    ls.Branch,
    ls.revenue AS Last_year_revenue,
    cs.revenue AS Current_year_revenue,
    ROUND(
        ((ls.revenue - cs.revenue) / ls.revenue) * 100,
        2
    ) AS revenue_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
USING (Branch)
ORDER BY revenue_ratio DESC
LIMIT 5;
```

### Business Insight

This identifies the top 5 branches experiencing the largest percentage decrease in revenue between the previous year and the current year.

---

# 🧠 Key SQL Concepts Demonstrated

## 1. Aggregate Functions

The project uses several SQL aggregate functions:

```sql
COUNT()
SUM()
AVG()
MIN()
MAX()
```

These functions are used to calculate transaction counts, quantities, revenue, profit, and ratings.

---

## 2. Window Functions

The project uses:

```sql
DENSE_RANK() OVER(
    PARTITION BY ...
    ORDER BY ...
)
```

This is useful for ranking categories, payment methods, and transaction days within specific groups.

For example:

```sql
DENSE_RANK() OVER(
    PARTITION BY Branch
    ORDER BY AVG(rating) DESC
)
```

This ranks categories based on their average rating separately for each branch.

---

## 3. Common Table Expressions — CTEs

The revenue comparison uses:

```sql
WITH revenue_2022 AS (...),
revenue_2023 AS (...)
```

CTEs make complex multi-step analytical queries easier to organize and understand.

---

## 4. Date Functions

The project uses MySQL date and time functions including:

```sql
STR_TO_DATE()
YEAR()
DAYNAME()
HOUR()
```

These functions are used for:

* Converting string dates
* Extracting years
* Finding weekdays
* Categorizing transactions by time of day

---

## 5. CASE Statement

The `CASE` statement is used to categorize transaction times:

```sql
CASE
    WHEN HOUR(`time`) < 12 THEN 'MORNING'
    WHEN HOUR(`time`) BETWEEN 12 AND 17 THEN 'AFTERNOON'
    ELSE 'EVENING'
END
```

---

# 🐍 Python Data Cleaning

The project uses Pandas for data preprocessing.

### Load Dataset

```python
import pandas as pd

df = pd.read_csv(
    'Walmart.csv',
    encoding_errors='ignore'
)
```

### Check Duplicate Records

```python
df.duplicated().sum()
```

The dataset contains **51 duplicate records** before cleaning.

### Remove Duplicates

```python
df.drop_duplicates(inplace=True)
```

### Check Missing Values

```python
df.isnull().sum()
```

### Remove Missing Values

```python
df.dropna(inplace=True)
```

After cleaning, the dataset contains **9,969 records**.

### Convert Unit Price

The original `unit_price` values contain `$`, so they are converted into numeric values:

```python
df['unit_price'] = (
    df['unit_price']
    .str.replace('$', '')
    .astype(float)
)
```

### Create Total Sales

```python
df['total'] = df['unit_price'] * df['quantity']
```

### Save Cleaned Dataset

```python
df.to_csv(
    'walmart_clean_data.csv',
    index=False
)
```

---

# 🔌 Python to MySQL Connection

The project uses **SQLAlchemy** and **PyMySQL** to connect Python with MySQL.

Install the required libraries:

```bash
pip install pandas sqlalchemy pymysql kagglehub
```

Import the required libraries:

```python
import pandas as pd
import pymysql
from sqlalchemy import create_engine
```

Create the MySQL connection:

```python
engine_mysql = create_engine(
    "mysql+pymysql://root:YOUR_PASSWORD@localhost:3306/walmart_db"
)
```

Load the cleaned DataFrame into MySQL:

```python
df.to_sql(
    name='walmart',
    con=engine_mysql,
    if_exists='append',
    index=False
)
```

> **Important:** Never upload your actual MySQL password to GitHub. Use `YOUR_PASSWORD` as a placeholder or store your credentials using environment variables.

---

# ⚙️ How to Run the Project

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/Walmart-Sales-Analysis.git
```

### 2. Navigate to the Project

```bash
cd Walmart-Sales-Analysis
```

### 3. Install Required Libraries

```bash
pip install pandas sqlalchemy pymysql kagglehub
```

### 4. Start MySQL

Make sure your MySQL server is running.

### 5. Create the Database

```sql
CREATE DATABASE walmart_db;
USE walmart_db;
```

### 6. Run the Python Notebook

Run the Jupyter Notebook to:

* Load the dataset
* Clean the data
* Remove duplicates
* Handle missing values
* Convert `unit_price`
* Create the `total` column
* Load the cleaned data into MySQL

### 7. Run SQL Queries

Execute the SQL queries from `walmart.sql` in MySQL Workbench.

---

# ⚠️ Important Data Note

The notebook's dataset preview contains transaction dates from **2019**, while the Q9 revenue comparison query is written for **2022 and 2023**.

Therefore, Q9 requires a dataset containing records from **2022 and 2023** for the year-over-year revenue comparison to produce meaningful results.

Make sure the date range in the dataset matches the years used in the SQL query.

---

# 📝 Query Improvement Note

For Q6, if the requirement is to display categories from **highest profit to lowest profit**, use:

```sql
ORDER BY total_profit DESC;
```

instead of:

```sql
ORDER BY 2;
```

`ORDER BY 2` refers to the second column in the `SELECT` statement and, without `DESC`, sorts it in ascending order.

---

# 🚀 Project Highlights

> A practical **SQL and Data Analysis project** combining **Python/Pandas data preprocessing with MySQL business analysis** to transform raw retail transaction data into meaningful business insights.

The project demonstrates how data can be:
Consider giving the repository a ⭐ on GitHub.
