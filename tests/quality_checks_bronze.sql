-- Checking for Nulls or Duplicates in Primary Key
-- 
USE CoffeeSales;

-- Test 1: General Counts

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM bronze.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM bronze.orders
UNION ALL
SELECT 'products', COUNT(*) FROM bronze.products;

-- Returned customers 1000 orders 1000 products 48

-- Test 2 Duplicates or Nulls in primary keys

-- Checking for nulls or duplicates on the bronze.customers table within the customer_id

SELECT
	customer_id,
	COUNT(*) AS duplicates_nulls
FROM 
	bronze.customers
GROUP BY
	customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL
ORDER BY duplicates_nulls DESC; -- returned 0 rows

-- Checking for nulls or duplicates on the bronze.orders table within the order_id

SELECT
	order_id,
	COUNT(*) AS duplicates_nulls
FROM 
	bronze.orders
GROUP BY
	order_id
HAVING COUNT(*) > 1 OR order_id IS NULL
ORDER BY duplicates_nulls DESC; -- returned 31 rows


-- Checking for nulls or duplicates on the bronze.product table within the product_id

SELECT
	product_id,
	COUNT(*) AS duplicates_nulls
FROM 
	bronze.products
GROUP BY
	product_id
HAVING COUNT(*) > 1 OR product_id IS NULL
ORDER BY duplicates_nulls DESC; -- returned 0 rows

-- Test 3: Checking for more Nulls

SELECT *
FROM bronze.customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR email IS NULL
   OR phone_number IS NULL
   OR address IS NULL 
   OR postcode IS NULL 
   OR loyalty_card IS NULL; 

SELECT *
FROM bronze.customers
WHERE email IS NOT NULL AND phone_number IS NOT NULL;    -- a good majority 691 cust have a phone and email


-- checking for nulls in orders

SELECT *
FROM bronze.orders
WHERE order_id IS NULL
   OR order_date IS NULL
   OR customer_id IS NULL
   OR product_id IS NULL
   OR quantity IS NULL
   OR sales IS NULL; -- basically here we have 1000 rows because there are multiple columns with null values
   -- customer_name, email, country, coffee_type, roast_type, size, unit_price, sales are all empty 

-- Checking for nulls in products
SELECT *
FROM bronze.products
WHERE product_id IS NULL
   OR unit_price IS NULL
   OR profit IS NULL; -- returned 0 rows

-- test 4 Broken Relationships 

SELECT o.* 
FROM bronze.orders o
LEFT JOIN bronze.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT o.*
FROM bronze.orders o
LEFT JOIN bronze.products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL; -- returned 0 rows

-- Test 5 Invalid Values 

SELECT *
FROM bronze.orders
WHERE quantity <= 0
   OR unit_price < 0
   OR sales < 0; -- returned 0

SELECT *
FROM bronze.products
WHERE unit_price < 0
   OR profit < 0
   OR size <= 0; -- returned 0


SELECT 
    COUNT(*) AS total_orders,
    COUNT(unit_price) AS orders_with_unit_price,
    COUNT(sales) AS orders_with_sales
FROM bronze.orders;


