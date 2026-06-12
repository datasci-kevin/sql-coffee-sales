USE CoffeeSales;
GO

-- Row counts
SELECT 'silver.customers' AS table_name, COUNT(*) AS total_rows FROM silver.customers
UNION ALL
SELECT 'silver.products', COUNT(*) FROM silver.products
UNION ALL
SELECT 'silver.orders', COUNT(*) FROM silver.orders;

-- Check duplicate or null customer IDs
SELECT customer_id, COUNT(*) AS total_rows
FROM silver.customers
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL;

-- Check duplicate or null product IDs
SELECT product_id, COUNT(*) AS total_rows
FROM silver.products
GROUP BY product_id
HAVING COUNT(*) > 1 OR product_id IS NULL;

-- Check missing keys in orders
SELECT *
FROM silver.orders
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR product_id IS NULL;

-- Check broken customer relationships
SELECT o.*
FROM silver.orders o
LEFT JOIN silver.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check broken product relationships
SELECT o.*
FROM silver.orders o
LEFT JOIN silver.products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Check invalid measures
SELECT *
FROM silver.orders
WHERE quantity <= 0
   OR unit_price < 0
   OR sales < 0;

-- Check sales calculation
SELECT *
FROM silver.orders
WHERE sales <> quantity * unit_price;
