CREATE DATABASE walmart_db;
USE walmart_db;
SHOW TABLES;
SELECT * FROM walmart LIMIT 5;
SELECT 
	payment_method,
    COUNT(*)
FROM walmart
GROUP BY 1;

SELECT DISTINCT Branch FROM walmart;

-- Business Problems
-- Q.1 Find different payment method and number of transactions, number of qty sold 
SELECT 
	payment_method,
	COUNT(invoice_id) AS No_of_tanzxn,
    SUM(quantity) AS no_of_qnt
FROM walmart
GROUP BY 1;

-- Q.2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
SELECT * FROM
(
	SELECT
		Branch,
		Category,
		ROUND(AVG(rating),2) AS AVG_rating,
		DENSE_RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_stat
	FROM walmart
	GROUP BY 1,2
) AS rank_table
WHERE rank_stat = 1;
-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT * FROM
(
SELECT  
	Branch,
	DAYNAME(STR_TO_DATE(`date`, '%d/%m/%Y')) AS DAY_Name,
    COUNT(invoice_id) AS Total,
    DENSE_RANK() OVER(PARTITION BY Branch ORDER BY COUNT(invoice_id) DESC) AS Highest_tnzxn
FROM walmart
GROUP BY 1,2
) AS high
WHERE Highest_tnzxn = 1;

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT * 
FROM
(
	SELECT 
		category,
		payment_method,
		sum(quantity),
		DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(quantity) DESC) AS ranky
	FROM walmart
	GROUP BY 1,2
) AS tot_rank
WHERE ranky=1;

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.
SELECT
	city,
    ROUND(AVG(rating),2) as average,
    MIN(rating) as minimum,
    MAX(rating) as maximum
FROM walmart
GROUP BY 1,category;
-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin).
-- List category and total_profit, ordered from highest to lowest profit.
SELECT 
	category,
    ROUND(SUM(total* profit_margin),2) AS total_profit 
FROM walmart
GROUP BY 1
ORDER BY 2;
 
-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
SELECT * FROM
(
	SELECT 
		Branch,
		payment_method,
		count(payment_method) as cnt,
		DENSE_RANK() OVER(PARTITION BY Branch ORDER BY COUNT(payment_method) DESC) AS method_rank
	FROM walmart
	GROUP BY 1,2
) AS rank_payment
WHERE method_rank = 1;
-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT 
	CASE
		WHEN HOUR(`time`) < 12 THEN 'MORNING'
		WHEN HOUR(`time`) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		ELSE 'EVENING'
	END AS shift,
    COUNT(invoice_id)
FROM walmart
GROUP BY shift;

-- Q.9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100
SELECT * FROM walmart LIMIT 6;
WITH revenue_2022
AS
(
	SELECT 
		Branch,
		ROUND(SUM(total),2) AS revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%Y')) = 2022
	GROUP BY 1
),
revenue_2023
AS
(
	SELECT 
		Branch,
		ROUND(SUM(total),2) AS revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(`date`, '%d/%m/%Y')) = 2023
	GROUP BY 1
)
SELECT
	ls.Branch,
    ls.revenue AS Last_year_revenue,
    cs.revenue AS Current_year_revenue,
    ROUND(((ls.revenue-cs.revenue)/ls.revenue)*100,2) AS revenue_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
USING(Branch)
ORDER BY 4 DESC
LIMIT 5












