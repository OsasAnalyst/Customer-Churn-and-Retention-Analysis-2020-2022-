
-- Real-time churn risk scoring as of Dec 2022
WITH active AS(
	SELECT
		cust_id,
        subscription_type,
        MAX(transaction_date) AS last_activity
	FROM customer_subscription_and_transaction_details
    WHERE transaction_type != 'churn'
    GROUP BY cust_id, subscription_type
),
avg_inactivity AS (
	SELECT 
		active.subscription_type,
        AVG(DATEDIFF(churn.transaction_date, active.last_activity)) AS avg_days_before_churn
	FROM active
    JOIN customer_subscription_and_transaction_details AS CHURN
		ON active.cust_id = churn.cust_id
        AND churn.transaction_type = 'churn'
	GROUP BY active.subscription_type
)
SELECT
	a.cust_id,
    a.subscription_type,
    DATEDIFF('2022-12-31', a.last_activity) AS days_inactive,
    CASE 
        WHEN DATEDIFF('2022-12-31', a.last_activity) > COALESCE(b.avg_days_before_churn, 700) THEN 'Critical Risk'
        WHEN DATEDIFF('2022-12-31', a.last_activity) > 600 THEN 'High Risk'
        WHEN DATEDIFF('2022-12-31', a.last_activity) > 365 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk_level,
    a.last_activity
FROM active a
LEFT JOIN avg_inactivity b 
  ON a.subscription_type = b.subscription_type
ORDER BY churn_risk_level DESC;