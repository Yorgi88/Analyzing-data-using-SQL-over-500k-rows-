-- SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
-- UNION ALL
-- SELECT 'sellers', COUNT(*) FROM sellers
-- UNION ALL
-- SELECT 'products', COUNT(*) FROM products
-- UNION ALL
-- SELECT 'category_translation', COUNT(*) FROM category_translation
-- UNION ALL
-- SELECT 'orders', COUNT(*) FROM orders
-- UNION ALL
-- SELECT 'order_items', COUNT(*) FROM order_items
-- UNION ALL
-- SELECT 'order_payments', COUNT(*) FROM order_payments
-- UNION ALL
-- SELECT 'order_reviews', COUNT(*) FROM order_reviews;

-- I did a quick row count to ensure it matches the expected range, which it does
-- lets create a staging table for each, we start with customers table first

-- Next step is to remove duplicates
-- Standardize the data
-- remove blank and null values
-- remove unnecessary columns
-- check the table each

SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM products;
SELECT * FROM category_translation;
-- SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM order_payments;
SELECT * FROM order_reviews;
SELECT * FROM orders;

WITH unique_customer AS (
	SELECT customers.customer_unique_id, COUNT(customers.customer_id) AS no_of_order 
    FROM customers
    INNER JOIN orders
    ON orders.customer_id = customers.customer_id
    GROUP BY customers.customer_unique_id
    ORDER BY no_of_order DESC
    LIMIT 10
)
SELECT * FROM unique_customer;        

-- This helps us identify the top ten customers based on order amount

SELECT * FROM customers;

-- lets try to remove duplicates

SELECT *, ROW_NUMBER() OVER(PARTITION BY customer_unique_id, customer_zip_code_prefix, customer_city) AS 
row_num
FROM customers
ORDER BY row_num desc;

SELECT 
    customer_unique_id, 
    COUNT(*) AS appearances,
    GROUP_CONCAT(DISTINCT customer_city) AS cities,
    GROUP_CONCAT(DISTINCT customer_state) AS states
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;

-- SELECT * FROM customers
-- WHERE customer_unique_id = '0d52f8cd8892f109a15803df169113b6';

-- SELECT * FROM orders WHERE customer_id = 'b540f2ed0a81891a303aab176a4f21b3';

SELECT * FROM customers_staging;

ALTER TABLE customers_staging
DROP COLUMN customer_zip_code_prefix;

update customers_staging
set customer_state = trim(customer_state);

SELECT * FROM orders;

select * from orders_staging;

-- INSERT INTO orders_staging
-- SELECT * FROM orders;

SELECT * FROM orders_staging
WHERE order_status = 'Delivered';

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_status,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_purchase,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS null_carrier,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated
FROM orders_staging;

SELECT * FROM order_payments_staging;

SELECT COUNT(DISTINCT order_id) AS counts FROM order_payments_staging;

WITH dups AS (
	SELECT order_id, COUNT(*) AS occurrence FROM order_payments_staging
    GROUP BY order_id
    HAVING COUNT(*) > 1
    ORDER BY occurrence desc
)
SELECT * FROM dups;

SELECT * FROM order_payments_staging
WHERE order_id = 'ccf804e764ed5650cd8759557269dc13';

SELECT * FROM orders_staging;
DESCRIBE orders_staging;

ALTER TABLE order_items_staging
MODIFY COLUMN shipping_limit_date DATE;
# We removed the time in the shipping_date, we want only the year/month/day

DESCRIBE order_items_staging;
-- UPDATE products_staging
-- SET
--    order_id = TRIM(order_id),
--    customer_id = TRIM(customer_id),
--    order_status = TRIM(order_status);

-- CREATE TABLE `products_staging` (
--   `product_id` varchar(50) NOT NULL,
--   `product_category_name` varchar(100) DEFAULT NULL,
--   `product_name_length` int DEFAULT NULL,
--   `product_description_length` int DEFAULT NULL,
--   `product_photos_qty` int DEFAULT NULL,
--   `product_weight_g` int DEFAULT NULL,
--   `product_length_cm` int DEFAULT NULL,
--   `product_height_cm` int DEFAULT NULL,
--   `product_width_cm` int DEFAULT NULL,
--   PRIMARY KEY (`product_id`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- CREATE TABLE products_staging LIKE products;
-- INSERT INTO products_staging SELECT * FROM products;

SELECT * FROM products_staging;
DESCRIBE products_staging;
INSERT INTO products_staging
SELECT * FROM products;

-- SELECT product_id, product_category_name FROM products_staging
-- GROUP BY product_id, product_category_name
-- HAVING COUNT(*) > 1;
-- For checking duplicates 

SELECT * FROM category_translation;
select * from products_staging;
SELECT COUNT(DISTINCT product_category_name) FROM products_staging;

ALTER TABLE products_staging
ADD COLUMN product_category_english VARCHAR(100);

-- we added a new column product_category_english to the products_staging
-- now we write a join between the products_staging and the category_translation table

UPDATE products_staging ps
JOIN category_translation ct
	ON ps.product_category_name = ct.product_category_name
SET ps.product_category_english = ct.product_category_name_english;

select count(distinct product_category_english) from products_staging;

select * from products_staging
where product_category_name and product_category_english = null or '';











