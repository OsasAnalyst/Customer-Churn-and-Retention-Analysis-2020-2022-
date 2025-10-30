
-- KPIs for 2022 - total_customers, MRR, churn rate
SELECT
	COUNT(DISTINCT cust_id) AS total_customers_2022,
    SUM(CASE WHEN transaction_type = 'initial' THEN subscription_price ELSE 0 END) AS total_mrr_2022,
    ROUND(
		COUNT(DISTINCT CASE WHEN transaction_type = 'churn' THEN cust_id END)
        / COUNT(DISTINCT cust_id) * 100, 1 
    ) AS churn_rate_2022_pct 
FROM customer_subscription_and_transaction_details
WHERE YEAR(transaction_date) = 2022;