#1 Create a View
CREATE VIEW rental_customer_informations AS
(
WITH
CUSTOM AS (
	SELECT customer_id AS cust, first_name,last_name, email
    FROM customer C
	),
RENTA AS (
	select customer_id ,COUNT(rental_id) AS rental_count
	from rental R
    GROUP BY customer_id
	)
SELECT R.customer_id,C.first_name, C.last_name, C.email , R.rental_count
FROM CUSTOM C, RENTA R
WHERE C.cust = R.customer_id
);
select * 
from rental_customer_informations;

#2 Create a Temporary Table
CREATE TEMPORARY TABLE total_amount_paid_by_customer
SELECT R.customer_id , CONCAT( first_name, ' ', last_name ) AS customer_name , SUM(rental_count * amount) AS total_paid
FROM rental_customer_informations R, payment P
WHERE R.customer_id = P.customer_id
GROUP BY R.customer_id, customer_name;

#3: Create a CTE and the Customer Summary Report
WITH
	RENTAL_VIEW AS (
		select * 
		from rental_customer_informations
	) ,
    CUSTOMER_PAYMT_SUMMARY_TEMP AS (
		select *
        from total_amount_paid_by_customer
    )
SELECT RV.first_name, RV.last_name, RV.email, RV.rental_count , CP.total_paid
FROM RENTAL_VIEW RV, CUSTOMER_PAYMT_SUMMARY_TEMP CP
WHERE RV.customer_id = CP.customer_id;

# Next, using the CTE, create the query to generate the final customer summary report,
# which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
# this last column is a derived column from total_paid and rental_count.
WITH
	RENTAL_VIEW AS (
		select * 
		from rental_customer_informations
	) ,
    CUSTOMER_PAYMT_SUMMARY_TEMP AS (
		select *
        from total_amount_paid_by_customer
    )
SELECT RV.first_name, RV.last_name, RV.email, RV.rental_count , CP.total_paid, ROUND(total_paid/rental_count,2) AS average_payment_per_rental
FROM RENTAL_VIEW RV, CUSTOMER_PAYMT_SUMMARY_TEMP CP
WHERE RV.customer_id = CP.customer_id;