/*
===============================================================================
SILVER LAYER - TABLE CREATION SCRIPT
===============================================================================

Author: Kevin Garcia
Project: Coffee Sales Data Warehouse
Layer: Silver (Cleaned & Enriched Data)

Description:
    This script creates the Silver layer tables.

    The Silver layer is responsible for:
    - Cleaning raw data from the Bronze layer
    - Standardizing values
    - Applying business transformations
    - Enriching data using joins and calculations
    - Preparing data for the Gold layer

===============================================================================
*/

USE CoffeeSales;
GO

-- Create silver schema if it does not already exist
IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'silver'
)
BEGIN
    EXEC('CREATE SCHEMA silver');
END;
GO

-- Drop existing Silver tables to allow a clean rebuild
DROP TABLE IF EXISTS silver.orders;
DROP TABLE IF EXISTS silver.customers;
DROP TABLE IF EXISTS silver.products;
GO

/*
===============================================================================
CREATE TABLE: silver.customers
Stores cleaned customer information from the Bronze layer.
===============================================================================
*/
CREATE TABLE silver.customers
(
    customer_id     VARCHAR(15),
    customer_name   VARCHAR(50),
    email           VARCHAR(100),
    phone_number    VARCHAR(50),
    address         VARCHAR(100),
    city            VARCHAR(50),
    country         VARCHAR(50),
    postcode        VARCHAR(25),
    loyalty_card    VARCHAR(10),
    creation_date   DATETIME2 DEFAULT GETDATE()
);
GO

/*
===============================================================================
CREATE TABLE: silver.products
Stores cleaned product information from the Bronze layer.
===============================================================================
*/
CREATE TABLE silver.products
(
    product_id      VARCHAR(15),
    coffee_type     VARCHAR(30),
    roast_type      VARCHAR(15),
    size            DECIMAL(10,2),
    unit_price      DECIMAL(10,2),
    price_per_100g  DECIMAL(10,2),
    profit          DECIMAL(10,2),
    creation_date   DATETIME2 DEFAULT GETDATE()
);
GO

/*
===============================================================================
CREATE TABLE: silver.orders
Stores cleaned and enriched order data.

Unit price is obtained from the Products table and
Sales is calculated as Quantity × Unit Price.
===============================================================================
*/
CREATE TABLE silver.orders
(
    order_id        VARCHAR(15),
    order_date      DATE,
    customer_id     VARCHAR(15),
    product_id      VARCHAR(15),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    sales           DECIMAL(10,2),
    creation_date   DATETIME2 DEFAULT GETDATE()
);
GO
