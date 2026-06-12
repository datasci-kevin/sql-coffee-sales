-- Check row counts
SELECT 'dim_customers' AS table_name, COUNT(*) AS total_rows FROM gold.dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'fact_orders', COUNT(*) FROM gold.fact_orders;


-- Check for missing dimension keys in fact table
SELECT *
FROM gold.fact_orders
WHERE customer_key IS NULL
   OR product_key IS NULL;


-- Check for invalid measures
SELECT *
FROM gold.fact_orders
WHERE quantity <= 0
   OR unit_price < 0
   OR sales < 0;

-- Check if sales calculation is correct
SELECT *
FROM gold.fact_orders
WHERE sales <> quantity * unit_price;

-- Sales by coffee type
SELECT
    p.coffee_type,
    SUM(f.sales) AS total_sales
FROM gold.fact_orders f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY p.coffee_type
ORDER BY total_sales DESC;

-- Sales by country
SELECT
    c.country,
    SUM(f.sales) AS total_sales
FROM gold.fact_orders f
LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY total_sales DESC;

-- checking for duplicate keys in products table
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products 
GROUP BY product_key
HAVING COUNT(*) > 1;

-- checking for duplicate customer ids in customers table
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

