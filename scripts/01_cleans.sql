USE DataWarehouse;
--1 ) database exploration
SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- 2) dimension exploration
SELECT DISTINCT country FROM gold.dim_customers;

SELECT DISTINCT gender FROM gold.dim_customers;

SELECT DISTINCT category, sub_category, product_name FROM gold.dim_products
ORDER BY 1,2,3;

-- 3) date exploration;
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(YEAR,MIN((order_date)),MAX(order_date)) AS order_range_year
FROM gold.fact_sales;

SELECT
	MIN(birthdate) AS youngest_customer,
	MAX(birthdate) AS oldest_customer
FROM gold.dim_customers;

SELECT
	*,
	DATEDIFF(YEAR,birthdate,GETDATE()) AS age
FROM gold.dim_customers;

-- 4) Measure Exploration
-- Find total sales
SELECT SUM(sales) total_sales FROM gold.fact_sales;

-- Find how many items are sold
SELECT SUM(quantity) no_of_saled_item FROM gold.fact_sales;

-- Find avg selling price
SELECT AVG(price) AS avg_price FROM gold.fact_sales;

-- Find total number of order
SELECT COUNT(order_number) AS total_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales;

-- Find total number of saled items
SELECT COUNT(quantity) AS total_quantity FROM gold.fact_sales;

-- Find total number of products
SELECT COUNT(product_key) as total_product FROM gold.dim_products;

SELECT COUNT(DISTINCT product_key) as total_product FROM gold.dim_products;

-- Find total number of customers
SELECT COUNT(customer_id) as total_cust FROM gold.dim_customers;

-- Find total number of customers that place any order
SELECT COUNT(DISTINCT customer_id) AS cust_orderd FROM gold.fact_sales;

-- 5) Magnitude Exploration

-- Find total number of customers by countries
SELECT country, COUNT(customer_id) total_customers FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Find total customer by Gender
SELECT gender, COUNT(customer_id) AS total_customers FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Find total product by category
SELECT category,COUNT(product_id) total_products FROM gold.dim_products 
GROUP BY category
ORDER BY total_products DESC;

-- What is the average cost in each category
SELECT category, AVG(cost) avg_price FROM gold.dim_products
GROUP BY category
ORDER BY avg_price DESC;

-- What is the total revenue generate form each category
select 
	dp.category,
	SUM(f.sales) AS total_revenue
from gold.fact_sales AS f
LEFT JOIN gold.dim_products AS dp
ON f.product_key = dp.product_key
GROUP BY category
ORDER BY total_revenue DESC;

-- What is the total revenue generate by each customer
SELECT
	dc.customer_key,
	dc.first_name,
	dc.last_name,
	sum(fs.sales) AS total_revenue_by_customer
FROM gold.dim_customers AS dc
LEFT JOIN gold.fact_sales AS fs
ON dc.customer_id = fs.customer_id
GROUP BY
	customer_key,
	first_name,
	last_name
ORDER BY total_revenue_by_customer DESC;

-- What is the distribution of items sold accross country

SELECT
	dc.country,
	SUM(fs.quantity) as total_sales_by_country
FROM gold.dim_customers AS dc
LEFT JOIN gold.fact_sales AS fs
ON dc.customer_id = fs.customer_id
GROUP BY dc.country
ORDER BY total_sales_by_country DESC;


-- 6) Ranking Exploration
-- Which 5 product generates highest revenue
SELECT TOP 5
    p.product_id,
    p.product_name,
    SUM(s.sales) AS total_rev
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON p.product_key = s.product_key
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_rev DESC;

-- what are the top 5 wrost performing product name 
SELECT TOP 5
    p.product_id,
    p.product_name,
    SUM(s.sales) AS total_rev
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON p.product_key = s.product_key
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_rev;


-- Find the top 10 cutomers who have generated the highest revenue

SELECT TOP 10
    c.customer_id,
	c.first_name,
    SUM(s.sales) AS total_rev
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_id = c.customer_id
GROUP BY
    c.customer_id,
	c.first_name
ORDER BY total_rev DESC;

-- the 3 customers with fewest order placed

SELECT TOP 3
    c.customer_id,
	c.first_name,
    SUM(s.sales) AS total_rev
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_id = c.customer_id
GROUP BY
    c.customer_id,
	c.first_name
ORDER BY total_rev ASC;