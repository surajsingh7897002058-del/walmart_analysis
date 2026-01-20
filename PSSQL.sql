SELECT count(*) FROM walmart;
SELECT * FROM walmart;

SELECT * FROM walmart;

SELECT 
	payment_method,
	count(*)
from walmart
GROUP BY 1;

SELECT
	count(DISTINCT branch) 
FROM walmart

--1. Analyze Payment Methods and Sales
--● Question: What are the different payment methods, and how many transactions and
--items were sold with each method?
--● Purpose: This helps understand customer preferences for payment methods, aiding in
--payment optimization strategies

SELECT
	payment_method,
	count(category) as no_transaction,
	sum(quantity) as item_sold
FROM walmart
GROUP BY 1;


--Question: Which category received the highest average rating in each branch?

SELECT *
FROM
(
	SELECT
		branch,
		category,
		AVG(rating) AS average_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE RANK = 1

--Question: What is the busiest day of the week for each branch based on transaction volume?

SELECT *
FROM
(
	SELECT
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) AS no_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE RANK = 1


--Question: How many items were sold through each payment method?

SELECT
	payment_method,
	sum(quantity) as item_sold
FROM walmart
GROUP BY 1;


--Question: What are the average, minimum, and maximum ratings for each category in each city?

SELECT
	city,
	category,
	AVG(rating) as avg_rating,
	min(rating) as min_rating,
	max(rating) as max_rating
FROM walmart
GROUP BY 1, 2;

--Question: What is the total profit for each category, ranked from highest to lowest?

SELECT
	category,
	sum(total) as total_revenue,
	sum(total * profit_margin) as total_profit
FROM walmart
GROUP BY 1
ORDER BY 1, 3 DESC

--Question: What is the most frequently used payment method in each branch?

SELECT *
FROM
(
	SELECT
		branch,
		payment_method,
		count(*) AS total_transaction,
		RANK() OVER(PARTITION BY branch ORDER BY count(*) DESC) AS RANK
	FROM walmart
	GROUP BY 1, 2
)
WHERE RANK = 1


--Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT
	branch,
CASE
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'afternoon'
		ELSE 'evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC


--Question: Which branches experienced the largest decrease in revenue compared to the previous year?
WITH revenue_2023 AS(
	SELECT
		branch,
		-- EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS YEAR,
		sum(total) as total_revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
),
revenue_2022 AS
	(SELECT
		branch,
		-- EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS YEAR,
		sum(total) as total_revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
	)

	SELECT
		r2022.branch,
		r2022.total_revenue as last_yr,
		r2023.total_revenue as currunt_yr,
		ROUND(((r2022.total_revenue - r2023.total_revenue)::NUMERIC/r2022.total_revenue)::NUMERIC * 100, 2) AS revenue_ratio
	FROM revenue_2023 as r2023
	join
	revenue_2022 as r2022
	ON 
	r2023.branch = r2022.branch
	WHERE r2023 < r2022
	ORDER BY 4 DESC LIMIT 5
	
SELECT * FROM walmart;