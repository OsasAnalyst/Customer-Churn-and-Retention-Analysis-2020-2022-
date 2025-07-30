
SELECT * FROM customer_subscription_and_transaction_details;






-- QUICK CHECK - TOTAL CUSTOMERS, MRR AND CHURN RATE

SELECT
	COUNT(DISTINCT cust_id) AS total_customer,
    SUM(CASE
			WHEN transaction_type = "initial" THEN subscription_price
            ELSE 0
		END) AS total_mrr,
	ROUND(COUNT(DISTINCT CASE WHEN transaction_type = "churn" THEN cust_id END) /
		  COUNT( DISTINCT cust_id) * 100.0) AS overall_churn_rate_percent
FROM customer_subscription_and_transaction_details;





-- SUSCRIPTION PLAN DISTRIBUTION - CURRENT ACTIVE SUSCRIPTIONS BY TYPE

WITH latest_subscription AS (
SELECT
	cust_id,
    subscription_type,
    ROW_NUMBER() OVER ( PARTITION BY cust_id ORDER BY transaction_type DESC) AS row_numbers
FROM customer_subscription_and_transaction_details
WHERE transaction_type != "churn"
)
SELECT
	subscription_type,
    COUNT(*) AS customers,
    ROUND( COUNT(*)/ SUM(COUNT(*)) OVER () * 100.0, 1) AS percentage_of_total
FROM latest_subscription
WHERE row_numbers = 1
GROUP BY 1;




-- CHURN ANALYSIS BY PLAN - CHURN RATE BY SUBSCRIPTION TIER

WITH churn_plan AS (
SELECT
	subscription_type,
    COUNT( DISTINCT cust_id) AS churned_customers
FROM customer_subscription_and_transaction_details
WHERE transaction_type = "churn"
GROUP BY 1
),
plan_total AS ( 
SELECT
	subscription_type,
    COUNT( DISTINCT cust_id) AS total_customers
FROM customer_subscription_and_transaction_details
WHERE transaction_type = "initial"
GROUP BY 1
)
SELECT 
	p.subscription_type,
    p.total_customers,
    c.churned_customers,
    ROUND(c.churned_customers/p.total_customers * 100, 1) AS churned_rate_percent
FROM churn_plan AS c JOIN plan_total AS p
on c.subscription_type = p.subscription_type;




-- COHORT RETENTION ANALYSIS - MONTHLY COHORT RETENTION 6/12/ABOVE 12  MONTHS

WITH cohort AS ( 
  SELECT
    cust_id,
    DATE(MIN(transaction_date)) AS cohort_date,
    DATE_FORMAT(MIN(transaction_date), '%Y-%m-01') AS cohort_month,
    subscription_type AS initial_plan
  FROM customer_subscription_and_transaction_details
  WHERE transaction_type = "initial"
  GROUP BY 1, 4
),
customer_activity AS (
  SELECT
    c.cust_id,
    c.cohort_month,
    c.initial_plan,
    c.cohort_date,
    MAX(CASE WHEN DATEDIFF(t.transaction_date, c.cohort_date) BETWEEN 1 AND 180 THEN 1 ELSE 0 END) AS active_6_months,
    MAX(CASE WHEN DATEDIFF(t.transaction_date, c.cohort_date) BETWEEN 1 AND 365 THEN 1 ELSE 0 END) AS active_12_months,
    MAX(CASE WHEN DATEDIFF(t.transaction_date, c.cohort_date) > 365 THEN 1 ELSE 0 END) AS active_above_12_months,
    MAX(CASE WHEN t.transaction_type = "CHURN" THEN 1 ELSE 0 END) AS has_churned
  FROM cohort c
  JOIN customer_subscription_and_transaction_details t ON c.cust_id = t.cust_id
  GROUP BY 1, 2, 3, 4
)
SELECT 
  cohort_month,
  initial_plan,
  COUNT(DISTINCT cust_id) AS cohort_size,
  ROUND(SUM(CASE WHEN has_churned = 0 AND active_6_months = 1 THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(DISTINCT cust_id), 1) AS retention_6_months_pct,
  ROUND(SUM(CASE WHEN has_churned = 0 AND active_12_months = 1 THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(DISTINCT cust_id), 1) AS retention_12_months_pct,
  ROUND(SUM(CASE WHEN has_churned = 0 AND active_above_12_months = 1 THEN 1 ELSE 0 END) * 100.0 / 
        COUNT(DISTINCT cust_id), 1) AS retention_above_12_month_pct
FROM customer_activity
GROUP BY 1, 2
ORDER BY 1, 2;






-- CHURN RATE BY SUBSCRIPTION PRICE POINT


SELECT 
  subscription_price,
  COUNT(DISTINCT cust_id) AS total_customers,
  COUNT(DISTINCT CASE WHEN transaction_type = 'CHURN' THEN cust_id END) AS churned,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN transaction_type = 'CHURN' THEN cust_id END) / 
        COUNT(DISTINCT cust_id), 1) AS churn_rate_pct
FROM customer_subscription_and_transaction_details
WHERE cust_id IN (SELECT DISTINCT cust_id FROM customer_subscription_and_transaction_details WHERE transaction_type = 'initial')
GROUP BY 1
ORDER BY 1;





-- PRE CHURN WARNING SIGN 

SELECT 
	t1.transaction_type,
    COUNT(DISTINCT t1.cust_id) AS customers,
    ROUND(COUNT(DISTINCT t1.cust_id) / 
		  (SELECT COUNT(DISTINCT cust_id) FROM customer_subscription_and_transaction_details 
           WHERE transaction_type = "churn") * 100 ,1) AS churn_percentage
FROM customer_subscription_and_transaction_details as t1 JOIN
	 customer_subscription_and_transaction_details as t2
     ON t1.cust_id = t2.cust_id AND
     t2.transaction_type = "churn" AND
     t1.transaction_date BETWEEN DATE_SUB(t2.transaction_date, INTERVAL 365 DAY) AND t2.transaction_date
WHERE t1.transaction_type IN ("reduction","upgrade")
GROUP BY 1;






-- CUSTOMER LIKELY TO CHURN - NO ACTIVITY IN 2 YEARS

SELECT 
	cust_id,
    MAX(transaction_date) AS last_activity_days,
	DATEDIFF("2022-12-01", MAX(transaction_date)) AS days_inactive,
    subscription_type AS current_plan
FROM customer_subscription_and_transaction_details
WHERE transaction_type != "churn"
GROUP BY 1, 4
HAVING days_inactive > 730
ORDER BY 3 DESC;






-- Highest Inactivity Periods Before Churn 


SELECT 
    subscription_type,
    MAX(days_inactive_before_churn) AS max_days_inactive,
    AVG(days_inactive_before_churn) AS avg_days_inactive,
    COUNT(*) AS churned_customers
FROM (
    SELECT
        t1.cust_id,
        t1.subscription_type,
        DATEDIFF(
            MAX(t2.transaction_date),
            MAX(t1.transaction_date)
        ) AS days_inactive_before_churn
    FROM customer_subscription_and_transaction_details AS t1 
    JOIN customer_subscription_and_transaction_details AS t2 
        ON t1.cust_id = t2.cust_id 
        AND t2.transaction_type = "churn"
    WHERE t1.transaction_type != "churn"
    GROUP BY t1.cust_id, t1.subscription_type 
) AS inactivity_periods
GROUP BY subscription_type
ORDER BY max_days_inactive DESC;





-- Real-Time Churn Risk Scoring

SELECT 
    current.cust_id,
    current.subscription_type,
    DATEDIFF("2022-12-01", current.last_activity) AS days_inactive,
    CASE 
        WHEN DATEDIFF("2022-12-01", current.last_activity) > 
             COALESCE((
                 SELECT AVG(DATEDIFF(churn.transaction_date, active.last_activity))
                 FROM (
                     SELECT cust_id, subscription_type, MAX(transaction_date) AS last_activity
                     FROM customer_subscription_and_transaction_details
                     WHERE transaction_type != 'churn'
                     GROUP BY cust_id, subscription_type
                 ) active
                 JOIN customer_subscription_and_transaction_details churn
                     ON active.cust_id = churn.cust_id AND churn.transaction_type = 'churn'
                 WHERE active.subscription_type = current.subscription_type
             ), 700) THEN 'CRITICAL RISK'
        WHEN DATEDIFF("2022-12-01", current.last_activity) > 600 THEN 'High Risk'
        WHEN current.subscription_type = 'PRO' AND DATEDIFF("2022-12-01", current.last_activity) > 365 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS churn_risk_score,
    current.last_activity AS last_activity_date
FROM (
    SELECT 
        cust_id, 
        subscription_type, 
        MAX(transaction_date) AS last_activity
    FROM customer_subscription_and_transaction_details
    WHERE transaction_type != 'churn'
    GROUP BY cust_id, subscription_type
) current;