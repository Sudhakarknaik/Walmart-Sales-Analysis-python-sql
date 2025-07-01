SELECT * FROM walmart;

--total count in table
SELECT COUNT(*) FROM walmart;

--distinct payment methods present
SELECT DISTINCT payment_method FROM walmart;

--how many transactions has been done in different payment method
SELECT payment_method,
COUNT(*)
FROM walmart
GROUP BY payment_method;

--total  different stores are present
SELECT COUNT(DISTINCT branch)
FROM walmart;

--bcoz some columns name in uppercase so drop table and and change into lowercase in python then upload
DROP TABLE walmart;

SELECT * FROM walmart;

--total  different stores are present
SELECT COUNT(DISTINCT branch)
FROM walmart;

--maximum qyantity
SELECT MAX(quantity)
FROM walmart;

--BUSINESS PROBLEMS.
--Q1. Find different payment methods and for each payment method number of transactions, number of quantity sold.
SELECT payment_method,
COUNT(*) AS no_payments,
SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

--Q2. Identify the highest rated category in each branch, displaying the branch,category and avr-rating.
--( created 2 columns avr_rating and rank)
--(showing in each branch the one product with highest ranking or rank=1 )
SELECT * FROM (
SELECT branch, category,
AVG(rating) AS avg_rating,
RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart
GROUP BY branch, category
)
WHERE rank = 1;

--Q3. Identify the busiest day for each branch based on the number of transactions.

--a. date is in text format so we have to convert by TO_DATE(date, 'DD/MM/YY')
--b. we need day only from formated_date column so used TO_CHAR
--c. in each branch the day that has highest number of sale
SELECT * FROM (
SELECT branch,
 TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
 COUNT(*) AS no_transactions,
 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY branch, day_name
)
WHERE rank = 1;

--Q4. Calculate the total quantity of items sold per payment method. list payment_method and total_quantity.
SELECT payment_method,
SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

--Q5. Determine the average, minimum, and maximum rating of category for each city.
--list the city, average_rating, min_rating, and max_rating.
SELECT city, category,
MIN(rating) AS min_rating,
MAX(rating) AS max_rating,
AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

--Q6. calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin). 
--list category and total_profit, ordered from highest to lowest profit.
SELECT category,
SUM(total) AS total_revenue,
SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category;

--Q7. Determine the most common payment method for each branch. 
--display branch and the preferref_payment_method.
--WITH cte AS () creates a temporary table.
WITH cte AS (
SELECT branch, payment_method,
COUNT(*) AS total_transact,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
FROM walmart
GROUP BY branch, payment_method
)
SELECT * FROM cte
WHERE rank = 1;


--Q8. Categorise sales into 3 group MORNING, AFTERNOON, EVENING
--Find out in each shift the number of invoices.
--(time column is in text has to convert to time)
SELECT branch,
CASE 
   WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'morning'
   WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'afternoon'
   ELSE 'evening'
END dat_time,
COUNT(*) 
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

--Q9. Identify the 5 branch with highest decrease ratio in revenue compare to last year 
--(current year 2023 and last year 2022)
--revenue decrease ratio formula--> rdr == ((last_rev)-(cur_rev))/last_rev.
--2022 sales
WITH revenue_2022 AS (
SELECT branch,
SUM(total) AS revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY 1
),
revenue_2023 AS
(
SELECT branch,
SUM(total) AS revenue
FROM walmart
WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY 1
)
SELECT ls.branch,
     ls.revenue AS last_year_revenue,
	 cs.revenue AS current_year_revenue,
	ROUND( 
	     (ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100,
		 2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC LIMIT 5;

--Q10. top 10 profit contribution cities

SELECT city, 
ROUND(SUM(total * profit_margin)::numeric, 2) AS total_profit
FROM walmart
GROUP BY city
ORDER BY total_profit DESC LIMIT 10;

--Q11 Branchwise contributions to total revenue
SELECT 
  branch,
  ROUND(SUM(total)::numeric, 2) AS branch_revenue,
  ROUND(
    100 * SUM(total)::numeric / SUM(SUM(total)::numeric) OVER (),
    2) AS revenue_percentage
FROM walmart
GROUP BY branch
ORDER BY branch_revenue DESC LIMIT 20;

--Q12 Classify days into Weekday/Weekend and compare their total sales.

SELECT
  CASE 
    WHEN EXTRACT(DOW FROM TO_DATE(date, 'DD/MM/YY')) IN (0, 6) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  ROUND(SUM(total)::numeric, 2) AS total_sales
FROM walmart
GROUP BY day_type;

--Q13 Categorize each transaction by spend using CASE WHEN logic for customer segmentation.


SELECT invoice_id, total,
  CASE 
    WHEN total >= 600 THEN 'High Value'
    WHEN total >= 300 THEN 'Medium Value'
    ELSE 'Low Value'
  END AS customer_segment
FROM walmart
ORDER BY total DESC;







































