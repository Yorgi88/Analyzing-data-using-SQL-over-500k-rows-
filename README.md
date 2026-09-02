===========================================================================
- AVG_ORDER_VALUE = $137.24
- TOTAL_REVENUE = $13,283,024.48 
- TOTAL_ORDERS = 98,666 / new: 96,790
- TOTAL_CUSTOMERS = 95,420  / new: 93,654 
Orders per Customer	96,790 / 93,654  = 1.0334
What this means: Most customers placed exactly 1 order. Only a very small percentage came back for a second purchase.

- YEARLY REVENUE
2016 - $43,381.61
2017 - $5,990,719.59
2018 - $7,248,923.28

- In the year 2016, most sales were made in October - $43,235.74
- in the year 2017, most sales were made in November - $992,047.17
- in the year 2018, most sales were made in May - $984,371.59

- After May 2018, there seems to be a decline in sales
- 2017 seems like their best year so far
===========================================================================





- We want to calculate the Sales using the olist dataset
- I've imported and cleaned the data using MySQL workbench
- In the products table, we created a staging table for it
-> called it products_staging

- in the products_staging, we added a new column to it
ALTER TABLE product_staging
ADD COLUMN product_category_english VARCHAR(100);

- Now we used a join operation - between the products_staging and category_translation table

- the join statement
- with this join we sql auto-matches the product_category_name in the products_staging and product_category_name in the category_translation table
- ##
- and then sets a translation in the new column -products_category_english

# UPDATE products_staging ps
# JOIN category_translation ct
#   ON ps.product_category_name = ct.product_category_name
# SET
#   ps.product_category_english = ct.product_category_name_english;

- Instead of making use of 5 tables for our sales analysis, its now been reduced to 4
- There is a bit of an issue, then i counted() the rows in the product_category english (in the products_staging)

- i am seeing 71 rows instead of 74
- i am also seeing some blanc and null values in the products_staging table
- (over 600 of them)

when we ran this script

SELECT ps.product_category, ct.product_category_name_english 
FROM products_staging ps
LEFT JOIN category_table
    ON ps.product_category_name = ct.product_category_name
WHERE ct.product_category_name_english is null
GROUP BY ps.product_category_name;

- we found out some cateogory not having a translation and blanks/null vals

- we also ran the script: 
SELECT * FROM products_staging
WHERE product_category_name = '' 
  AND product_category_english IS NULL;

- 610 rows were returned

- so we clean by tagging the product_category_english as 'uncategorized'

- UPDATE products_staging
-- SET product_category_english = 'Uncategorized'
-- WHERE product_category_name = '' 
--   AND product_category_english IS NULL;

- we also clean some category with no tranlsation by giving them one

- ## see analyzing_olist_brazil file for the analysis done

- We gonna start the analysis now
- We're going to start from the top and work our way down the bottom

- Let's start with these 4
- TOTAL REVENUE
- TOTAL ORDERS
- TOTAL CUSTOMERS
- AOV [Average Order Value]

- what is revenue ?
- ##Revenue = The total amount of money a company earns from selling its - - -  products or services.

customers -> orders -> order_items -> products
- i successfully wrote created a view called sales_summary
- it comprises of 4 tables that's needed for the analysis

- Now, i ran this: select distinct order_status from orders_staging;
- and i think we should only focus on 'delivered' and 'invoiced'
- for the revenue calculation

- Now , we can answer the very top 4 questions
- also, note for the AVG order value, use this formula

- ## AOV = Total Revenue ÷ Total Orders

- I managed to put these findings into CTEs makes the whole thing clean
- and readable -- see the analyzing_olist_brazil file

- AVG_ORDER_VALUE = 134.63
- TOTAL_REVENUE = 13,283,024.48
- TOTAL_ORDERS = 98,666
- TOTAL_CUSTOMERS = 95,420 

Orders per Customer	98,666 / 95,420 = 1.034
What this means: Most customers placed exactly 1 order. Only a very small percentage came back for a second purchase.

It tells you that the business is great at acquiring new customers, but not great at retaining them. 

- Next, we look at the Yearly, monthly revenue, we also gonna look at seasonality

- seasons like easter, christmas and all that, where there could be sales spikes

- First, i want to start with the yearly revenue, and i am thinking of using 
- stored procedures
- stored procedures contain reusable sql scripts and can take in parameters
- i like to think of them as functions()
- 
- i created the stored procedure to calc the yearly revenue
- all you have to do is slot in the year as parameter
- CALL get_yearly_revenue(2016); 
 -- see the analyzing_olist_brazil file --

 - next, i want to find the entire monthly revenue for a particular year
 - when we say
 - CALL get_all_monthly_revenue(- would take in year as paremeters)
 - We get the entire months jan - dec

 - tried using the LAG() function to compare previous momths
 - SELECT MONTH(order_purchase_timestamp) AS `month`, 
		ROUND(SUM(price), 2) AS revenue ,
        LAG(ROUND(SUM(price), 2)) OVER(ORDER BY MONTH(order_purchase_timestamp)) AS previous_month_revenue
        FROM sales_summary
        WHERE YEAR(order_purchase_timestamp) = 2017
        GROUP BY MONTH(order_purchase_timestamp)
        ORDER BY MONTH(order_purchase_timestamp) ;


## We made an error so far in the TOTAL_ORDERS, TOTAL_CUSTOMERS, AOV, get_yearly_revenue(), get_monthly()

- i created fresh stored_procedures:  get_yearly_revenue(), get_monthly()
- dropped the old ones

- i forgot to always include: order_status IN ('delivered', 'invoiced');
- This is crucial, because without it, sql also includes all order_statuses
- like 'shipped' , 'approved', etc

- next, i created a stored procedure for getting all the month's revenue
- for each year and compare with previous month

- and i also added a LAG() which is used here to compare the monthly earnings
- with LAG() we can look at March 2017 earnings and compare it will February 2017, to see how sales did
- CALL monthly_revenue_compare(2018);  -- see the analyzing_olist_brazil file

- Next, we now want to look at revenue by city and state

- we've been able to look at the top performing states and cities
- as well as the percentage they each contribute to the total revenue
- see the analyzing_olist_brazil file

