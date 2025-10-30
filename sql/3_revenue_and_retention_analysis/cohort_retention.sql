
-- Cohort retention (6, 12, >12 months)
WITH cohort AS (
	SELECT
		cust_id,
        DATE_FORMAT(MIN(transaction_date), '%Y-%m-01') AS cohort_month,
        MIN(transaction_date) AS cohort_start,
        subscription_type AS initial_plan
	FROM customer_subscription_and_transaction_details
	WHERE transaction_type = 'initial'
	GROUP BY cust_id, subscription_type
),
activity AS (
	SELECT
		c.cust_id,
        c.cohort_month,
        c.initial_plan,
        MAX( CASE WHEN t.transaction_date = 'churn' THEN 1 ELSE 0 END) AS churn_flag,
        MAX(DATEDIFF(t.transaction_date, c.cohort_start)) AS days_since_join
	FROM cohort AS c
    JOIN customer_subscription_and_transaction_details AS t
		ON c.cust_id = t.cust_id
    GROUP BY c.cust_id, c.cohort_month, c.initial_plan  
)
SELECT
	cohort_month,
    initial_plan,
    COUNT(DISTINCT cust_id) AS cohort_size,
    ROUND(SUM(CASE WHEN churn_flag = 0 AND days_since_join <= 180 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS retention_6m_pct,
    ROUND(SUM(CASE WHEN churn_flag = 0 AND days_since_join <= 365 THEN 1 ELSE 0 END) * 100.0/COUNT(*), 1) AS retention_12m_pct,
    ROUND(SUM(CASE WHEN churn_flag = 0 AND days_since_join > 365 THEN 1 ELSE 0 END) * 100.0/COUNT(*), 1) AS retention_over_12m_pct
FROM activity
GROUP BY cohort_month, initial_plan
ORDER BY cohort_month;

