
-- Pre-churn activities like reduction or upgrade within 12 months before churn
SELECT
	t1.transaction_type AS pre_churn_action,
    COUNT(DISTINCT t1.cust_id) AS customers_involved,
    ROUND(
		COUNT(DISTINCT t1.cust_id) * 100.0 /
        (SELECT COUNT(DISTINCT cust_id)
         FROM customer_subscription_and_transaction_details
         WHERE transaction_type = 'churn'), 1
    ) AS percent_of_churned_customers
FROM customer_subscription_and_transaction_details AS t1
JOIN customer_subscription_and_transaction_details AS t2
	ON t1.cust_id = t2.cust_id
	AND t2.transaction_type = 'churn'
	AND t1.transaction_date BETWEEN DATE_SUB(t2.transaction_date, INTERVAL 365 DAY) AND t2.transaction_date
WHERE t1.transaction_type IN ('reduction', 'upgrade')
GROUP BY pre_churn_action
ORDER BY percent_of_churned_customers DESC;
