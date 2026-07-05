
/*
===============================================================================
05 - Ranking Analysis
===============================================================================
Purpose:
    Identify top-performing customers, products, countries, and product
    categories based on sales performance.
===============================================================================
*/

-- Who are the top 10 best customers by total sales?
SELECT *
FROM (
    SELECT
        c.customer_key,
        c.customer_name,
        SUM(o.sales) AS sales_amount,
        ROW_NUMBER() OVER(ORDER BY SUM(o.sales) DESC) AS customer_ranking
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.customer_key,
        c.customer_name
) AS t
WHERE customer_ranking <= 10
ORDER BY sales_amount DESC;


-- What are the top 10 products by total sales?
SELECT *
FROM (
    SELECT
        p.product_key,
        p.coffee_type,
        SUM(o.sales) AS sales_amount,
        ROW_NUMBER() OVER(ORDER BY SUM(o.sales) DESC) AS product_ranking
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY
        p.product_key,
        p.coffee_type
) AS t
WHERE product_ranking <= 10
ORDER BY sales_amount DESC;


-- Rank countries by total sales.

SELECT
    c.country,
    SUM(o.sales) AS sales_amount,
    RANK() OVER(ORDER BY SUM(o.sales) DESC) AS country_rank
FROM gold.fact_orders AS o
LEFT JOIN gold.dim_customers AS c
    ON o.customer_key = c.customer_key
GROUP BY c.country
ORDER BY country_rank;


-- Which roast type generates the most sales?
SELECT *
FROM (
    SELECT
        p.roast_type,
        SUM(o.sales) AS sales_amount,
        ROW_NUMBER() OVER(ORDER BY SUM(o.sales) DESC) AS roast_type_ranking
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY p.roast_type
) AS t
WHERE roast_type_ranking <= 10
ORDER BY sales_amount DESC;


-- What coffee size generates the most sales?

SELECT *
FROM (
    SELECT
        p.size_category,
        SUM(o.sales) AS sales_amount,
        ROW_NUMBER() OVER(ORDER BY SUM(o.sales) DESC) AS size_ranking
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY p.size_category
) AS t
WHERE size_ranking <= 10
ORDER BY sales_amount DESC;


-- What are the top 3 customers of each country?

WITH customer_country_sales AS (
    SELECT
        c.country,
        c.customer_key,
        c.customer_name,
        SUM(o.sales) AS sales_amount
    FROM gold.fact_orders AS o
    LEFT JOIN gold.dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY
        c.country,
        c.customer_key,
        c.customer_name
),
ranked_customers AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY country
            ORDER BY sales_amount DESC
        ) AS customer_rank
    FROM customer_country_sales
)
SELECT *
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY country, customer_rank;
