USE CoffeeSales;
GO

TRUNCATE TABLE silver.customers;


INSERT INTO silver.customers (
    customer_id,
    customer_name,
    email,
    phone_number,
    address,
    city,
    country,
    postcode,
    loyalty_card
)
SELECT
    TRIM(customer_id),
    TRIM(customer_name),
    LOWER(TRIM(email)),
    TRIM(phone_number),
    TRIM(address),
    TRIM(city),
    TRIM(country),
    TRIM(postcode),
    TRIM(loyalty_card)
FROM bronze.customers;

TRUNCATE TABLE silver.products;

INSERT INTO silver.products (
    product_id,
    coffee_type,
    roast_type,
    size,
    size_category,
    unit_price,
    price_per_100g,
    profit
)
SELECT
    TRIM(product_id),
    TRIM(coffee_type),
    CASE
        WHEN TRIM(roast_type) = 'L' THEN 'Light'
        WHEN TRIM(roast_type) = 'M' THEN 'Medium'
        WHEN TRIM(roast_type) = 'D' THEN 'Dark'
        ELSE 'Unknown'
    END AS roast_type,
    size,
    CASE
        WHEN size = 0.20 THEN 'Small'
        WHEN size = 0.50 THEN 'Medium'
        WHEN size = 1.00 THEN 'Large'
        WHEN size = 2.50 THEN 'Extra Large'
        ELSE 'Unknown'
    END AS size_category,
    unit_price,
    price_per_100g,
    profit
FROM bronze.products;


TRUNCATE TABLE silver.orders;

INSERT INTO silver.orders (
    order_id,
    order_date,
    customer_id,
    product_id,
    quantity,
    unit_price,
    sales
)
SELECT
    TRIM(o.order_id),
    o.order_date,
    TRIM(o.customer_id),
    TRIM(o.product_id),
    o.quantity,
    p.unit_price,
    o.quantity * p.unit_price
FROM bronze.orders o
LEFT JOIN bronze.products p
    ON o.product_id = p.product_id;


