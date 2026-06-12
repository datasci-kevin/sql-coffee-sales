CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_name,
    email,
    phone_number,
    address,
    city,
    country,
    postcode,
    loyalty_card
FROM silver.customers;
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    coffee_type,
    roast_type,
    size,
    unit_price,
    price_per_100g,
    profit
FROM silver.products;
GO

CREATE OR ALTER VIEW gold.fact_orders AS
SELECT
    o.order_id,
    c.customer_key,
    p.product_key,
    o.order_date,
    o.quantity,
    o.unit_price,
    o.sales
FROM silver.orders o
LEFT JOIN gold.dim_customers c
    ON o.customer_id = c.customer_id
LEFT JOIN gold.dim_products p
    ON o.product_id = p.product_id;
GO
