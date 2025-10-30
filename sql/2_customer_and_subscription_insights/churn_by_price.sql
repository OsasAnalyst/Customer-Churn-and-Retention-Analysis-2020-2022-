
-- Churn rate by price point
SELECT
	subscription_price,
    COUNT(DISTINCT cust_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN transaction_type = 'churn' THEN cust_id END) AS churned_customers,
    ROUND(
		COUNT(DISTINCT CASE WHEN transaction_type = 'churn' THEN cust_id END) * 100.0
        /  COUNT(DISTINCT cust_id), 1
    ) AS churn_rate_pct
FROM customer_subscription_and_transaction_details
WHERE YEAR(transaction_date) BETWEEN 2020 AND 2022
GROUP BY subscription_price
ORDER BY subscription_price;