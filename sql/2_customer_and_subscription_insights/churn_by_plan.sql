
-- Churn rate by plan type across full period
WITH churned AS (
	SELECT
		subscription_type,
        COUNT(DISTINCT cust_id) AS churned_customers
	FROM customer_subscription_and_transaction_details
    WHERE transaction_type = 'CHURN'
    GROUP BY subscription_type
),
base AS (
	SELECT subscription_type,
    COUNT(DISTINCT cust_id) AS total_customers
    FROM customer_subscription_and_transaction_details
    WHERE subscription_type IN ('BASIC', 'PRO', 'MAX')
    GROUP BY subscription_type
)
SELECT
	b.subscription_type,
    b.total_customers,
    COALESCE(c.churned_customers, 0) AS churned_customers,
    ROUND(COALESCE(c.churned_customers, 0) * 1.0 / b.total_customers, 3) AS churn_rate_ratio,
    ROUND(COALESCE(c.churned_customers, 0) *100.0 / b.total_customers, 1) AS churn_rate_pct
FROM base AS b
LEFT JOIN churned AS C ON b.subscription_type = c.subscription_type
ORDER BY churn_rate_pct DESC;