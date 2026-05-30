USE CoffeeSales;
GO

-- Create bronze schema if it does not already exist
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'bronze'
)
BEGIN
    EXEC('CREATE SCHEMA bronze');
END;
GO

-- Drop existing bronze tables to allow a clean rebuild
DROP TABLE IF EXISTS bronze.customers;
DROP TABLE IF EXISTS bronze.orders;
DROP TABLE IF EXISTS bronze.products;
GO

-- Raw customer data from customers.csv
CREATE TABLE bronze.customers (
    customer_id VARCHAR(15),
    customer_name VARCHAR(50),
    email VARCHAR(100),
    phone_number VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    postcode VARCHAR(25),
    loyalty_card VARCHAR(10)
);

-- Raw order/sales data from orders.csv
CREATE TABLE bronze.orders (
    order_id VARCHAR(15),
    order_date DATE,
    customer_id VARCHAR(15),
    product_id VARCHAR(15),
    quantity INT,
    customer_name VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50),
    coffee_type VARCHAR(30),
    roast_type VARCHAR(15),
    size DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    sales DECIMAL(10,2)
);

-- Raw product data from products.csv
CREATE TABLE bronze.products (
    product_id VARCHAR(15),
    coffee_type VARCHAR(30),
    roast_type VARCHAR(15),
    size DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    price_per_100g DECIMAL(10,2),
    profit DECIMAL(10,2)
);
