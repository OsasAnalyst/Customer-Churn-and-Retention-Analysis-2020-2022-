
-- Identity customers with >2 years inactivity before 2022
SELECT
	cust_id,
    subscription_type,
    MAX(transaction_date) AS last_active_date,
    DATEDIFF('2022-12-31', MAX(transaction_date)) AS days_inactive
FROM customer_subscription_and_transaction_details
WHERE transaction_type != 'churn'
GROUP BY cust_id, subscription_type
HAVING days_inactive > 730
ORDER BY days_inactive DESC;

-- Average inactivity before churn per plan
SELECT
	subscription_type,
    AVG(days_inactive_before_churn) AS avg_inactive_days,
    MAX(days_inactive_before_churn) AS max_inactive_days,
    COUNT(*) AS churned_customers
FROM (
	SELECT
		t1.cust_id,
        t1.subscription_type,
        DATEDIFF(MAX(t2.transaction_date), MAX(t1.transaction_date)) AS days_inactive_before_churn
	FROM customer_subscription_and_transaction_details AS t1
    JOIN customer_subscription_and_transaction_details AS t2
		ON t1.cust_id = t2.cust_id
        AND t2.transaction_type = 'CHURN'
	WHERE t1.transaction_type != 'CHURN'
    GROUP BY t1.cust_id, t1.subscription_type
) AS inactivity
GROUP BY subscription_type
ORDER BY avg_inactive_days DESC;