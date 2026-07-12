-- 1) Change over time
-- How have total sales changed over the years?
SELECT
    YEAR(order_date) AS year,
    DATENAME(MONTH,order_date) AS month,
    SUM(sales) AS max_total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),DATENAME(MONTH,order_date)
ORDER BY year;

-- sales by country
SELECT
    c.country,
    SUM(s.sales) AS max_total_sales
FROM gold.dim_customers AS c
INNER JOIN gold.fact_sales AS s
    ON c.customer_id = s.customer_id
GROUP BY c.country
ORDER BY c.country;

-- which product most salesd in which country
select * from
(select
    rank() over(partition by country order by max_total_sales_by_product desc) as rn,
    t.country,
    t.max_total_sales_by_product,t.product_namE
from (SELECT 
c.country,
p.product_name,
sum(s.sales) max_total_sales_by_product
from
gold.fact_sales as s
inner join gold.dim_products as p
    on s.product_key = p.product_key
inner join gold.dim_customers as c
    on s.customer_id = c.customer_id
GROUP BY country,p.product_name)t)tt
WHERE tt.rn = 1;


-- calculate maximum sales year by country
 with cte1 as (
 SELECT
        c.country,
        sum(s.sales) AS max_total_sales,
        YEAR(s.order_date) AS year
    FROM
    gold.fact_sales AS s
    INNER JOIN gold.dim_customers AS c
        ON s.customer_id = c.customer_id
    GROUP BY country,YEAR(s.order_date)),
    CTE2 AS (
select RANK() OVER(PARTITION BY CTE1.COUNTRY ORDER BY CTE1.max_total_sales DESC) AS rnk,* from cte1 
where cte1.country IN ('Germany','United States','Australia','United Kingdom','Canada','France') AND cte1.year IS NOT NULL)
SELECT * FROM CTE2 WHERE CTE2.rnk = 1;

-- calculate Minimum sales year by country
 with cte1 as (
 SELECT
        c.country,
        sum(s.sales) AS min_total_sales,
        YEAR(s.order_date) AS year
    FROM
    gold.fact_sales AS s
    INNER JOIN gold.dim_customers AS c
        ON s.customer_id = c.customer_id
    GROUP BY country,YEAR(s.order_date)),
    CTE2 AS (
select RANK() OVER(PARTITION BY CTE1.COUNTRY ORDER BY CTE1.min_total_sales ASC) AS rnk,* from cte1 
where cte1.country IN ('Germany','United States','Australia','United Kingdom','Canada','France') AND cte1.year IS NOT NULL)
SELECT * FROM CTE2 WHERE CTE2.rnk = 1;