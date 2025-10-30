
-- Executive summary (2022 focus)
SELECT
	COUNT(DISTINCT cust_id) AS total_customers,
    SUM(subscription_price) AS total_revenue,
    COUNT(DISTINCT CASE WHEN transaction_type = 'churn' THEN cust_id END) AS churn,
    ROUND(
		COUNT(DISTINCT CASE WHEN transaction_type = 'churn' THEN cust_id END) * 100.0
        / COUNT(DISTINCT cust_id), 1
    ) AS churn_rate_pct,
    ROUND(
		(SUM(CASE WHEN transaction_type != 'churn' THEN subscription_price ELSE 0 END)
        / SUM(subscription_price)) * 100, 1
    ) AS revenue_retained_pct
FROM customer_subscription_and_transaction_details
WHERE YEAR(transaction_date) = 2022;