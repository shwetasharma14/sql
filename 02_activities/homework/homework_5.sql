-- Cross Join
/*1. Suppose every vendor in the `vendor_inventory` table had 5 of each of their products to sell to **every** 
customer on record. How much money would each vendor make per product? 
Show this by vendor_name and product name, rather than using the IDs.

HINT: Be sure you select only relevant columns and rows. 
Remember, CROSS JOIN will explode your table rows, so CROSS JOIN should likely be a subquery. 
Think a bit about the row counts: how many distinct vendors, product names are there (x)?
How many customers are there (y). 
Before your final group by you should have the product of those two queries (x*y).  */

DROP TABLE IF EXISTS vendor_product_customer_join;
CREATE TEMPORARY TABLE vendor_product_customer_join AS
SELECT DISTINCT vi.vendor_id, vi.product_id, c.customer_id 
	from vendor_inventory as vi, customer c
	ORDER by vi.vendor_id, vi.product_id;

SELECT * FROM vendor_product_customer_join;
SELECT * FROM vendor_inventory;

DROP TABLE IF EXISTS vendor_product_customer__price;
CREATE TEMPORARY TABLE vendor_product_customer__price AS
SELECT distinct vpc.*, vi.original_price
FROM vendor_product_customer_join vpc
JOIN vendor_inventory vi
on vi.vendor_id = vpc.vendor_id AND vi.product_id = vpc.product_id;

SELECT v.vendor_name, vpcp.vendor_id, 
	p.product_name, vpcp.product_id, 
	sum(vpcp.original_price) as money_per_vendor_product
FROM vendor_product_customer__price as vpcp
INNER JOIN vendor v ON v.vendor_id = vpcp.vendor_id
INNER JOIN product p ON p.product_id = vpcp.product_id
GROUP BY vpcp.vendor_id, vpcp.product_id;

-- INSERT
/*1.  Create a new table "product_units". 
This table will contain only products where the `product_qty_type = 'unit'`. 
It should use all of the columns from the product table, as well as a new column for the `CURRENT_TIMESTAMP`.  
Name the timestamp column `snapshot_timestamp`. */

DROP TABLE if EXISTS product_units;
CREATE TEMP TABLE product_units as
	SELECT *, CURRENT_TIMESTAMP as snapshot_timestamp
	FROM product
	WHERE product_qty_type = 'unit';

SELECT * FROM product_units
ORDER BY product_id DESC;

/*2. Using `INSERT`, add a new row to the product_units table (with an updated timestamp). 
This can be any product you desire (e.g. add another record for Apple Pie). */

INSERT INTO product_units
VALUES(24, "Shweta's product", "4 dozens", 7, 'unit', CURRENT_TIMESTAMP);

SELECT * FROM product_units
ORDER BY product_id DESC;

-- DELETE
/* 1. Delete the older record for the whatever product you added. 

HINT: If you don't specify a WHERE clause, you are going to have a bad time.*/

With numbered_product_units as (
	SELECT *, 
		row_number() OVER(PARTITION BY product_name ORDER BY snapshot_timestamp) as time_rank
	FROM product_units
)
DELETE from product_units 
WHERE snapshot_timestamp = (
	SELECT snapshot_timestamp from numbered_product_units
	WHERE time_rank = 1 and product_id = 24)
	AND product_id = 24;


SELECT * FROM product_units
ORDER BY product_id DESC, snapshot_timestamp DESC;

-- UPDATE
/* 1.We want to add the current_quantity to the product_units table. 
First, add a new column, current_quantity to the table using the following syntax.

ALTER TABLE product_units
ADD current_quantity INT;

Then, using UPDATE, change the current_quantity equal to the last quantity value from the vendor_inventory details.

HINT: This one is pretty hard. 
First, determine how to get the "last" quantity per product. 
Second, coalesce null values to 0 (if you don't have null values, figure out how to rearrange your query so you do.) 
Third, SET current_quantity = (...your select statement...), remembering that WHERE can only accommodate one column. 
Finally, make sure you have a WHERE statement to update the right row, 
	you'll need to use product_units.product_id to refer to the correct row within the product_units table. 
When you have all of these components, you can run the update statement. */

ALTER TABLE product_units
ADD current_quantity INT;

DROP TABLE IF EXISTS qty_ranks;
CREATE TEMPORARY TABLE qty_ranks as
SELECT *,
 row_number() OVER(PARTITION by product_id order by market_date DESC) as last_qty
 from vendor_inventory
order by product_id, market_date DESC, quantity DESC;

DROP TABLE IF EXISTS product_last_quantities;
CREATE TEMPORARY TABLE product_last_quantities as
SELECT * 
	from qty_ranks
	WHERE last_qty = 1;
	
SELECT * from qty_ranks;
SELECT * from product_last_quantities;

UPDATE product_units as p
SET current_quantity = coalesce(
						(SELECT quantity
							FROM product_last_quantities as plq 
							WHERE plq.product_id = p.product_id), 
						0);

SELECT * from product_units;
