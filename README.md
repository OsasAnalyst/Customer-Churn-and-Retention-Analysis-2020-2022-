# Customer Churn and Retention Analysis (2020–2022)

---

## 🧭 Project Overview

This project analyzes **customer churn and retention trends** for *SkinBloom*, a DTC skincare subscription brand.  
The goal was to uncover why customers leave, when they leave, and how to retain them for longer.  

We worked with three years of transactional data (2020–2022), combining **SQL feature engineering** and **Power BI visualization** to create an actionable, business-focused story.

**Tools Used:** MySQL, Power BI, Excel, GitHub  

Churn analysis matters because improving retention even by **5%** can increase profits by **25–95%**.  
This analysis helps translate customer data into strategies that stop revenue leakage and build loyalty.

![Dashboard Overview](https://github.com/user-attachments/assets/040854c2-b166-4f1c-a535-e1878c9a6c34)

---

## Executive Summary

**2022 Story:**  
SkinBloom closed 2022 with strong growth — **$619.58K total revenue**, **6.37K customers**, and an **85.9% retention rate**.  
But behind this growth lies a hidden problem: **churn increased by 10%**, and **revenue lost to churn peaked in Q3 2022**.

**Key Insights**
- **Basic tier is the churn hotspot**, with a churn rate of **13.78%**, the highest of all tiers.  
- **MAX subscribers** deliver over **2x the lifetime value (LTV)** of Basic users ($123 vs. $52).  
- Most churn occurs **within the first 2–3 months** of subscription — the critical “early risk” period.  
- Once customers cross the **6-month mark**, their value grows exponentially, with **revenue retention reaching 278% by month 35**.

---

## Context and Business Problem

Between 2020 and 2022, SkinBloom grew rapidly in both subscribers and revenue.  
However, this success masked a deeper issue: a **persistent churn rate of 14.1%** in 2022, meaning growth depended heavily on replacing lost customers.  

Churn is not just a customer count issue — it’s a **profitability problem**.  
Every customer who leaves represents not only lost subscription revenue but also **lost lifetime value**.  

**The Challenge:**  
Retention risk now outweighs acquisition growth.  
This project was designed to pinpoint **who is leaving, when, and why**, and to provide clear recommendations to turn churn into loyalty.

![Churn Context Visual](https://github.com/user-attachments/assets/6af22403-aebe-454f-b574-199213c90e5a)

---

## ⚙️ Data and Methodology

### Data Sources
- **FactCustomerTransaction** – core table containing all customer transaction details  
- **DimSubscription, DimDate, DimReferral, DimCustomer** – supporting dimension tables for context

### Key Transformations
- **Cohort Creation** – grouped customers by their first transaction month  
- **Month Since Join** – calculated tenure using `DATEDIFF(transaction_date, cohort_start)`  
- **Churn Flag** – tagged customers as Churned / Active based on last transaction type  
- **Revenue Retained %** – tracked revenue from initial cohort over time  
- **Retention Segmentation** – New (<1 month), Returning (<6 months), Loyal (>6 months)

### Tools and Workflow
1. **MySQL** — for cleaning, cohort building, and churn signal creation  
2. **Power BI** — for DAX measures, visualization, and storytelling  
3. **Excel** — for quick validation and export  


**Example SQL:**
```sql
SELECT subscription_type,
       ROUND(COUNT(DISTINCT CASE WHEN transaction_type='churn' THEN cust_id END)
       *100.0 / COUNT(DISTINCT cust_id),2) AS churn_rate_pct
FROM customer_subscription_and_transaction_details
GROUP BY subscription_type;
````

---

## Insights and Analysis

### 1. Subscription Behavior

* **Basic plan**: Largest customer base but weakest retention
* **MAX plan**: Strongest loyalty, highest LTV ($123), and lowest churn
* Customers often **upgrade** from Basic → PRO → MAX, showing natural value progression

![Churn by Plan Chart](https://github.com/user-attachments/assets/a4522916-423c-434b-be2c-438eae42fac4)

### 2. Retention and Loyalty

* Churn risk peaks within **first 3 months** of joining
* Customers who stay **beyond 6 months** become highly loyal
* **Revenue Retained %** grows from **100% to 278% by Month 35**, proving loyalty drives higher spend

![Revenue Retention Curve](https://github.com/user-attachments/assets/e04cb2f6-8f52-4180-8b59-c5b7b8519599)

### 3. Segment Contribution

* Loyal segment now contributes the **majority of stable revenue ($270K in 2022)**
* Revenue Lost to Churn peaked in **Q3 2022**, highlighting the need for early re-engagement

![Revenue_Lost_to_Churn](https://github.com/user-attachments/assets/4a7129e6-db11-4d6c-b635-dc2c6b2f2f70)

---

## 🧠 Recommendations

| Strategy                              | Expected Impact                                            | Metric to Track            |
| ------------------------------------- | ---------------------------------------------------------- | -------------------------- |
| **1. Fortify the First 90 Days**      | Reduce early churn by 5% among Basic users                 | Retention @ 6 months       |
| **2. Predictive Intervention System** | Trigger alerts for 300-day inactivity & downgrade attempts | Revenue Lost to Churn      |
| **3. Reward Loyal Users**             | Boost LTV of PRO & MAX tiers                               | Upgrade-to-Downgrade Ratio |

### Additional Recommendations

* Launch personalized onboarding emails for Basic tier
* Set automatic alerts for customers nearing 300 days inactive
* Offer small loyalty rewards or upgrades after 12 months


---

## 🚀 Future Work

* **Build a predictive churn model** using machine learning to forecast at-risk users
* **Run A/B tests** on retention emails and discount offers
* **Automate churn risk dashboard** in Power BI for real-time alerts

These next steps turn insight into action — helping SkinBloom stay proactive instead of reactive.



---

## 🗂️ Repository Structure

```
├── data/                 # Raw and cleaned datasets  
├── sql/                  # SQL scripts for churn & cohort analysis  
├── powerbi/              # PBIX files or DAX measures  
├── images/               # Screenshots for README  
├── presentation/         # PowerPoint storytelling deck  
└── README.md             # This file
```

---

## 🧩 Tech Stack

* **SQL (MySQL):** Data cleaning, cohort segmentation, churn detection
* **Power BI:** KPI creation, retention analysis, dashboard storytelling
* **Excel:** Quick validation and exports
* **GitHub:** Documentation and version control

---

## ✉️ Author

**Osaretin Idiagbonmwen**
*Data Analyst | SQL | Power BI | Data Storytelling*

📧 [Linkedin page](https://www.linkedin.com/in/osaretin-idiagbonmwen-33ab85339)

---

> “Customer retention is not just a metric — it’s a relationship. The longer they stay, the more they spend, and the more your business grows.”

---
