-- AGGREGATE
/* 1. Write a query that determines how many times each vendor has rented a booth 
at the farmer’s market by counting the vendor booth assignments per vendor_id. */
SELECT vendor_id, count(*) as booth_rentals
FROM vendor_booth_assignments
GROUP BY vendor_id;


/* 2. The Farmer’s Market Customer Appreciation Committee wants to give a bumper 
sticker to everyone who has ever spent more than $2000 at the market. Write a query that generates a list 
of customers for them to give stickers to, sorted by last name, then first name. 

HINT: This query requires you to join two tables, use an aggregate function, and use the HAVING keyword. */
SELECT c.customer_id, 
c.customer_last_name,
c.customer_first_name, 
sum(cp.quantity * cp.cost_to_customer_per_qty) AS customer_spending

FROM customer AS c
LEFT JOIN customer_purchases AS cp
ON c.customer_id = cp.customer_id

GROUP BY cp.customer_id
HAVING customer_spending > 2000
ORDER BY c.customer_last_name, c.customer_first_name;


--Temp Table
/* 1. Insert the original vendor table into a temp.new_vendor and then add a 10th vendor: 
Thomass Superfood Store, a Fresh Focused store, owned by Thomas Rosenthal

HINT: This is two total queries -- first create the table from the original, then insert the new 10th vendor. 
When inserting the new vendor, you need to appropriately align the columns to be inserted 
(there are five columns to be inserted, I've given you the details, but not the syntax) 

-> To insert the new row use VALUES, specifying the value you want for each column:
VALUES(col1,col2,col3,col4,col5) 
*/
DROP TABLE IF EXISTS temp_vendor;

CREATE TEMP TABLE temp_vendor AS
SELECT * FROM vendor;

INSERT INTO temp_vendor(vendor_id, vendor_name, vendor_type, vendor_owner_first_name, vendor_owner_last_name)
VALUES (10, "Thomas's Superfood Store", "Fresh Focused", "Thomas", "Rosenthal");

SELECT * FROM temp_vendor;

-- Date
/*1. Get the customer_id, month, and year (in separate columns) of every purchase in the customer_purchases table.

HINT: you might need to search for strfrtime modifers sqlite on the web to know what the modifers for month 
and year are! */
SELECT customer_id, 
CASE strftime('%m', market_date)
    WHEN '01' THEN 'January'
    WHEN '02' THEN 'February'
    WHEN '03' THEN 'March'
    WHEN '04' THEN 'April'
    WHEN '05' THEN 'May'
    WHEN '06' THEN 'June'
    WHEN '07' THEN 'July'
    WHEN '08' THEN 'August'
    WHEN '09' THEN 'September'
    WHEN '10' THEN 'October'
    WHEN '11' THEN 'November'
    WHEN '12' THEN 'December'
END AS month, 
strftime('%Y',market_date) AS year
from customer_purchases;

/* 2. Using the previous query as a base, determine how much money each customer spent in April 2019. 
Remember that money spent is quantity*cost_to_customer_per_qty. 

HINTS: you will need to AGGREGATE, GROUP BY, and filter...
but remember, STRFTIME returns a STRING for your WHERE statement!! */
SELECT cp.customer_id, cust.customer_first_name, cust.customer_last_name,
CAST(strftime('%m', cp.market_date) AS INT) AS month, 
strftime('%Y',cp.market_date) AS year,
sum(cp.quantity * cp.cost_to_customer_per_qty) AS amount_spent

from customer_purchases AS cp
LEFT JOIN customer AS cust
	ON cp.customer_id = cust.customer_id
where month = 4 and year = '2019'

GROUP BY cp.customer_id;
