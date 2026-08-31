===========================================================================
- AVG_ORDER_VALUE = $134.63
- TOTAL_REVENUE = $13,283,024.48
- TOTAL_ORDERS = 98,666
- TOTAL_CUSTOMERS = 95,420 
Orders per Customer	98,666 / 95,420 = 1.034
What this means: Most customers placed exactly 1 order. Only a very small percentage came back for a second purchase.

- YEARLY REVENUE
2016 - $49,785.92
2017 - $6,155,806.98
2018 - $7,386,050.80

- 


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
