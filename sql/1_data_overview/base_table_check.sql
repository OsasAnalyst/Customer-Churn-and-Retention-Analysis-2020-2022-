
-- Inspect the raw data
SELECT *
FROM customer_subscription_and_transaction_details
LIMIT 20;


-- Time range check
SELECT
	MIN(transaction_date) AS first_record_date,
    MAX(transaction_date) AS last_record_date,
    COUNT(*) AS total_records
FROM customer_subscription_and_transaction_details;