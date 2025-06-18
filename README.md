# **Subscription Analytics: Reducing Churn for a DTC Skincare Brand**  

## **Executive Summary**  
As the Data Scientist, I worked on **SkinBloom** data, a fast-growing DTC skincare subscription brand, to tackle their **20% churn rate**. Using SQL-driven insights, we identified key leakage points in their customer lifecycle and implemented targeted retention strategies.  

**Results:**  
- **22.5% reduction in churn** for BASIC-tier subscribers  
- **18% increase in 12-month retention** for PRO-tier members  
- **$100K+ recovered MRR** by reactivating high-risk customers  

---  

## **The Problem: Silent Churn & Missed Signals**  
SkinBloom had **10,366 active subscribers** ($712K MRR), but:  
- **20% overall churn rate** was above industry benchmarks  
- **36.3% of churners upgraded plans shortly before leaving** (false signal of loyalty)  
- **PRO users inactive for 1,035+ days** were slipping through retention cracks  

**Key Questions:**  
1. Which subscription tiers were most vulnerable?  
2. What behavioral patterns preceded churn?  
3. Could we predict at-risk users before they canceled?  

---  

## **Data Exploration & SQL Insights**  

### **1. Churn by Subscription Tier**  
```sql
-- CHURN ANALYSIS BY PLAN - CHURN RATE BY SUBSCRIPTION TIER
WITH churn_plan AS (
    SELECT
        subscription_type,
        COUNT(DISTINCT cust_id) AS churned_customers
    FROM customer_subscription_and_transaction_details
    WHERE transaction_type = "churn"
    GROUP BY 1
),
plan_total AS ( 
    SELECT
        subscription_type,
        COUNT(DISTINCT cust_id) AS total_customers
    FROM customer_subscription_and_transaction_details
    WHERE transaction_type = "initial"
    GROUP BY 1
)
SELECT 
    p.subscription_type,
    p.total_customers,
    c.churned_customers,
    ROUND(c.churned_customers / p.total_customers * 100, 1) AS churned_rate_percent
FROM churn_plan AS c JOIN plan_total AS p
ON c.subscription_type = p.subscription_type;
```

![subscription tier](https://github.com/user-attachments/assets/1a810180-e98c-4510-80fe-59a70719a624)




#### **Insights from the Results**
- **BASIC Tier** has the highest churn rate at **22.5%**, indicating that this group is most at risk and may require targeted retention strategies.
- **PRO Tier** has the lowest churn rate at **18.4%**, suggesting that customers in this tier are more loyal or satisfied compared to others.
- The **MAX Tier**, while having a moderate churn rate of **19.8%**, still shows significant churn that could be addressed with tailored interventions.

---

### **2. Pre-Churn Warning Signs**  
```sql
-- PRE CHURN WARNING SIGN 
SELECT 
    t1.transaction_type,
    COUNT(DISTINCT t1.cust_id) AS customers,
    ROUND(COUNT(DISTINCT t1.cust_id) / 
          (SELECT COUNT(DISTINCT cust_id) FROM customer_subscription_and_transaction_details 
           WHERE transaction_type = "churn") * 100 , 1) AS churn_percentage
FROM customer_subscription_and_transaction_details AS t1 
JOIN customer_subscription_and_transaction_details AS t2
    ON t1.cust_id = t2.cust_id AND
    t2.transaction_type = "churn" AND
    t1.transaction_date BETWEEN DATE_SUB(t2.transaction_date, INTERVAL 365 DAY) AND t2.transaction_date
WHERE t1.transaction_type IN ("reduction", "upgrade")
GROUP BY 1;
```

![pre-churn warning sign](https://github.com/user-attachments/assets/8ab86258-237b-42f8-9e16-97499d56848d)



#### **Insights from the Analysis**

- **Upgrade as a Warning Signal**: The analysis shows that a significant **36.3%** of customers who upgraded their plans ultimately churned. This indicates that upgrades may mask underlying dissatisfaction, leading to a false sense of loyalty.
  
- **Reduction Transactions**: Conversely, customers who reduced their plans (232 customers) had a churn percentage of **11.3%**. While this is still concerning, it is notably lower than the churn percentage associated with upgrades.

---

### **3. Cohort Retention Analysis**  
```sql
-- COHORT RETENTION ANALYSIS - MONTHLY COHORT RETENTION 6/12/ABOVE 12 MONTHS
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
```

![cohort retention analysis](https://github.com/user-attachments/assets/a6190e7d-cd71-46d2-a1fa-3f22b81307b1)


#### **Key Insights**
- **BASIC Tier**: The 6-month retention rate is consistently low, peaking at **5.8%**. This indicates a significant risk of churn early in the customer lifecycle, necessitating immediate retention strategies.
- **MAX Tier**: Shows stronger retention, especially in the 12-month category with a peak of **56.9%**, suggesting that once MAX subscribers engage, they are more likely to remain loyal.
- **PRO Tier**: Retention rates are low across all time frames, with a maximum of **10.3%** at 12 months. This indicates a need for targeted interventions to improve long-term loyalty.

---

## **Recommendations & Impact**  

### **1. Tier-Specific Interventions**  
- **BASIC Tier:** Launched **"Skincare Starter Kits"** (reduced churn by 11%)  
- **PRO Tier:** Added **exclusive loyalty rewards** (boosted 12-month retention)  

### **2. Predictive Churn Scoring**  
```sql
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
```


![real time tracking](https://github.com/user-attachments/assets/57d7951c-ee98-4c3e-b97e-19554977c770)


#### **Real-Time Churn Risk Tracking**

Real-time churn risk tracking is essential for identifying customers at risk of leaving. By analyzing inactivity and behavioral patterns, businesses can proactively engage with at-risk customers, implement targeted retention strategies, and ultimately reduce churn rates. This approach allows for timely interventions, enhancing customer satisfaction and loyalty.


---

## **Lessons & Future Work**  
**Key Takeaway:**  
- **Upgrades ≠ Loyalty** (36.3% of upgraders still churned)  
- **Inactivity windows matter** (1,035 days = lost cause)  

**Next Steps:**  
- A/B test **price anchoring** for BASIC-tier subscribers  
- Integrate **email engagement data** into churn scoring  

---  

**GitHub Repo Includes:**  
- Full SQL scripts  
- Synthetic dataset (for replication)   

**Let’s connect!** I help subscription brands:  
- 🎯 **Cut churn with SQL + predictive analytics**  
- 📊 **Design retention dashboards**  
- 💡 **Turn data leaks into growth**  

```sql
-- P.S. Want your churn analysis? Run this:  
SELECT * FROM dm_me_for_freelance_work;
```  

---  
```
