/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category,
       sub-category, product line, and cost.
    2. Segments products by revenue into High-Performer,
       Mid-Range, or Low-Performer.
    3. Aggregates product-level metrics:
       - Total Orders
       - Total Sales
       - Total Quantity Sold
       - Total Customers
       - Product Lifespan (Months)
    4. Calculates valuable KPIs:
       - Recency (Months Since Last Sale)
       - Average Selling Price
       - Average Order Revenue (AOR)
       - Average Monthly Revenue
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS
(
/*---------------------------------------------------------------------------
1) Base Query
---------------------------------------------------------------------------*/
SELECT
    f.order_number,
    f.order_date,
    f.customer_id,
    f.sales,
    f.quantity,

    p.product_id,
    p.product_key,
    p.product_name,
    p.category_id,
    p.category,
    p.sub_category,
    p.cost,
    p.product_line,
    p.start_date,
    p.maintainance

FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key

WHERE f.order_date IS NOT NULL
),

product_aggregations AS
(
/*---------------------------------------------------------------------------
2) Product Aggregations
---------------------------------------------------------------------------*/
SELECT

    product_id,
    product_key,
    product_name,
    category_id,
    category,
    sub_category,
    cost,
    product_line,
    start_date,
    maintainance,

    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,

    MAX(order_date) AS last_sale_date,

    COUNT(DISTINCT order_number) AS total_orders,

    COUNT(DISTINCT customer_id) AS total_customers,

    SUM(sales) AS total_sales,

    SUM(quantity) AS total_quantity,

    ROUND(
        AVG(CAST(sales AS FLOAT) / NULLIF(quantity,0))
    ,2) AS avg_selling_price

FROM base_query

GROUP BY

    product_id,
    product_key,
    product_name,
    category_id,
    category,
    sub_category,
    cost,
    product_line,
    start_date,
    maintainance
)

/*---------------------------------------------------------------------------
3) Final Product Report
---------------------------------------------------------------------------*/
SELECT

    product_id,
    product_key,
    product_name,
    category_id,
    category,
    sub_category,
    cost,
    product_line,
    start_date,
    maintainance,

    last_sale_date,

    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,

    total_orders,

    total_sales,

    total_quantity,

    total_customers,

    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;