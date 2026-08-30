- We want to calculate the Sales using the olist dataset
- I've imported and cleaned the data using MySQL db
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