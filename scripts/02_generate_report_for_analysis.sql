SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 'Total Quantity', SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT 'Average Price', ROUND(AVG(price), 2)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Orders', COUNT(DISTINCT order_number)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Transactions', COUNT(*)
FROM gold.fact_sales

UNION ALL

SELECT 'Total Products', COUNT(DISTINCT product_key)
FROM gold.dim_products

UNION ALL

SELECT 'Total Customers', COUNT(DISTINCT customer_id)
FROM gold.fact_sales;