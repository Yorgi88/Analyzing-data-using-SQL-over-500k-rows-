-- here, we do our analysis

select * from customers_staging;
select * from products_staging;
select * from orders_staging;
select distinct order_status from orders_staging;
select * from order_items_staging;

-- I think we'll need to use a view
CREATE OR REPLACE VIEW sales_summary AS
SELECT cs.customer_unique_id, cs.customer_state,
	   os.order_status, os.order_id, os.order_purchase_timestamp,
       ois.order_item_id , ois.price, ois.freight_value, ps.product_category_english
FROM customers_staging cs
JOIN orders_staging os
	ON cs.customer_id = os.customer_id
JOIN order_items_staging ois
	ON os.order_id = ois.order_id
JOIN products_staging ps
	ON ois.product_id = ps.product_id;
       

SELECT * FROM sales_summary;
SELECT COUNT(order_id ) as ords FROM sales_summary;

-- SELECT 
-- 	ROUND(SUM(price), 2) AS total_revenue,
--     COUNT(DISTINCT order_id) AS total_orders,
--     ROUND AS average_order_value
-- FROM sales_summary;

WITH total_revenue AS (
	SELECT ROUND(SUM(price), 2) AS revenue FROM sales_summary
    WHERE order_status IN ('invoiced', 'delivered')
),
total_customers AS (
	SELECT COUNT(DISTINCT customer_unique_id) as customer_count FROM sales_summary
    WHERE order_status in ('delivered', 'invoiced')
),

total_orders AS (
	SELECT COUNT(DISTINCT order_id) as order_count FROM sales_summary
    WHERE order_status in ('delivered', 'invoiced')
)
-- SELECT revenue FROM total_revenue;
-- SELECT order_count FROM total_orders;
-- SELECT customer_count FROM total_customers;
SELECT
	ROUND((SELECT revenue FROM total_revenue) / (SELECT order_count FROM total_orders), 2) AS avg_order_value;
       
-- SELECT DISTINCT MONTH(order_purchase_timestamp) AS `MONTH`, 
-- YEAR(order_purchase_timestamp)  AS `YEAR` FROM sales_summary;

DELIMITER $$
CREATE PROCEDURE get_yearly_revenue(IN `year` INT)
BEGIN
    SELECT ROUND(SUM(price), 2) AS total_revenue
    FROM sales_summary
    WHERE YEAR(order_purchase_timestamp) = `year`
      AND order_status IN ('delivered', 'invoiced');
END $$
DELIMITER ;
CALL get_yearly_revenue(2018);


SELECT MONTH(order_purchase_timestamp) AS `month`, 
		ROUND(SUM(price), 2) AS revenue ,
        LAG(ROUND(SUM(price), 2)) OVER(ORDER BY MONTH(order_purchase_timestamp)) AS previous_month_revenue
        FROM sales_summary
        WHERE YEAR(order_purchase_timestamp) = 2017
        GROUP BY MONTH(order_purchase_timestamp)
        ORDER BY MONTH(order_purchase_timestamp) ;


-- next is states and city

-- RECAP
-- Create a stored procedure that gives you the entire monthly revenue
-- just by inputting the year

DELIMITER $$
CREATE PROCEDURE get_monthly(IN `year` INT)
BEGIN
	SELECT MONTH(order_purchase_timestamp) AS `month` , ROUND(SUM(price), 2) AS revenue
    FROM sales_summary
    WHERE YEAR(order_purchase_timestamp) = `year`
    AND order_status in ('delivered', 'invoiced')
    GROUP BY MONTH(order_purchase_timestamp)
    ORDER BY `month`;
END $$
DELIMITER ;
CALL get_monthly(2016);



SELECT MONTH(order_purchase_timestamp) AS `month`, ROUND(SUM(price), 2) AS revenue,
LAG(ROUND(SUM(price), 2)) OVER(ORDER BY MONTH(order_purchase_timestamp)) AS prev_revenue
FROM sales_summary
WHERE order_status IN ('delivered', 'invoiced')
AND YEAR(order_purchase_timestamp) = 2016
GROUP BY MONTH(order_purchase_timestamp)
ORDER BY MONTH(order_purchase_timestamp);
-- Now, can we turn the script above into a stored_procedure?

DELIMITER $$
CREATE PROCEDURE monthly_revenue_compare(IN `year` int)
BEGIN
	SELECT MONTH(order_purchase_timestamp) AS `month`, ROUND(SUM(price), 2) AS revenue,
LAG(ROUND(SUM(price), 2)) OVER(ORDER BY MONTH(order_purchase_timestamp)) AS prev_revenue
FROM sales_summary
WHERE YEAR(order_purchase_timestamp) = `year`
AND order_status IN ('delivered', 'invoiced')
GROUP BY MONTH(order_purchase_timestamp)
ORDER BY `month`;
END $$
DELIMITER ;
CALL monthly_revenue_compare(2018);












