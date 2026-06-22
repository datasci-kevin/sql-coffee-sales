/*
===============================================================================
04 - Magnitude Analysis
===============================================================================
Purpose:
    Analyze measures by dimensions, such as customers by country,
    products by category, and sales by product/customer attributes.
===============================================================================
*/

-- find the total number of customers by country
SELECT
    country,
    COUNT(customer_id) AS total_customers
FROM
    gold.dim_customers
GROUP BY country 
ORDER BY total_customers DESC;
    
-- what country generates more sales?

SELECT
    c.country,
    SUM(o.sales) AS total_sales
FROM
    gold.fact_orders AS o
LEFT JOIN
    gold.dim_customers as c 
ON 
    o.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;

-- What type of coffee sells the most?
SELECT
    p.coffee_type,
    SUM(o.sales) AS total_sales
FROM
    gold.fact_orders AS o
LEFT JOIN
    gold.dim_products as p
ON 
    o.product_key = p.product_key
GROUP BY
    p.coffee_type 
ORDER BY 
    total_sales DESC;
    
-- What size of coffe sells the most?

SELECT
    p.size_category,
    SUM(o.sales) AS total_sales
FROM
    gold.fact_orders AS o
LEFT JOIN
    gold.dim_products as p
ON 
    o.product_key = p.product_key
GROUP BY
    p.size_category
ORDER BY 
    total_sales DESC;


-- What roast type sells the most?
SELECT
    p.roast_type,
    SUM(o.sales) AS total_sales
FROM
    gold.fact_orders AS o
LEFT JOIN
    gold.dim_products as p
ON 
    o.product_key = p.product_key
GROUP BY
    p.roast_type
ORDER BY 
    total_sales DESC;


-- Which customers buy more??

SELECT TOP 10
    c.customer_key,
    c.customer_name,
    SUM(o.sales) AS total_sales
FROM
    gold.fact_orders AS o
LEFT JOIN
    gold.dim_customers AS c 
ON o.customer_key = c.customer_key
GROUP BY 
    c.customer_key,
    c.customer_name 
ORDER BY 
    total_sales DESC;

-- 

SELECT
    p.coffee_type,
    SUM(o.sales) AS total_sales,
    SUM(o.quantity) AS total_quantity
FROM gold.fact_orders AS o
LEFT JOIN gold.dim_products AS p
    ON o.product_key = p.product_key
GROUP BY p.coffee_type
ORDER BY total_sales DESC;

