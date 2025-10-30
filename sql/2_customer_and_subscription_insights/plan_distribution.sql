-- Distribution of active subscriptions by customers
WITH latest_subscription AS (
	SELECT
		cust_id,
        subscription_type,
        ROW_NUMBER() OVER (PARTITION BY cust_id ORDER BY transaction_date DESC) AS rn
	FROM customer_subscription_and_transaction_details
    WHERE transaction_type != 'CHURN'
)
SELECT
	subscription_type,
    COUNT(*) AS active_customers,
    ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS percent_of_total
FROM latest_subscription
WHERE rn = 1
GROUP BY subscription_type
ORDER BY active_customers DESC;
