📊 Foodie-Fi Subscription Analytics – Project Report



📌 Project Overview

This project simulates a real-world end-to-end SQL analytics solution for a subscription-based streaming service, Foodie-Fi. The goal is to analyze customer subscription behavior, revenue trends, churn patterns, and support strategic decisions using data stored in SQL and visualized in Tableau/Power BI/Python.





🎯 Objectives

Understand and track subscription lifecycle events: sign-up, upgrades, downgrades, churn.

Generate a 2020 payments table using historical plan and subscription data.

Build performance dashboards using Tableau, Power BI, or Python.

Derive business insights from key metrics such as revenue, retention, growth, and churn.





🛠️ Tools Used

SQL: Data extraction, transformation, payments generation

MySQL: Database management

Python / Tableau / Power BI: Visualization and dashboards (To be added)

GitHub: Version control and project showcase





🧱 Database Tables \& Structure

plans: Plan details including pricing and billing period.

customer\_plans / customer\_plan\_history: Historical record of customer plan subscriptions.

subscriptions: Initial state (customer sign-up).

payments: Generated payment data for all paying customers in 2020.



See ERD diagram in /docs/erd.png





⚙️ Data Processing Steps

Extracted subscription period per customer using SQL LEAD() window function.

Created a stored procedure to loop through all customer subscriptions.

Inserted monthly or annual payments into payments table based on billing frequency.

Validated payment integrity (no duplicates, no invalid dates).

Aggregated insights for revenue, churn, upgrades, downgrades, etc.





📈 Key Metrics \& Analysis

1\. 💰 Revenue Metrics

Plan Name		Count	Total Revenue

Basic Monthly (1)	3402	- $33,679.80

Pro Monthly (2) 	2882	- $57,351.80

Pro Annual (3)	 	258 	- $51,342.00

Total				 $142,373.60



-> Annual plan contributes highest revenue per transaction.

-> Monthly plans drive higher volume, lower per-customer revenue.





2\. 📈 Customer Growth Rate



'''

SELECT MONTH(payment\_date) AS month, COUNT(DISTINCT customer\_id) AS new\_customers

FROM payments

GROUP BY month

ORDER BY month;

'''



Monthly customer additions reveal seasonality and marketing impact.



3\. 🔁 Plan Downgrades \& Upgrades

'''

SELECT \* FROM customer\_plan\_history

WHERE plan\_name IN ('pro monthly', 'pro annual') AND

      customer\_id IN (

        SELECT customer\_id FROM customer\_plan\_history

        WHERE plan\_name = 'basic monthly'

      );

'''



Identifies customers moving from higher to lower-tier plans.





4\. 📉 Churn Analysis

'''SELECT customer\_id FROM customer\_plan\_history

WHERE plan\_name = 'churn';

'''



Total churned customers.

Breakdown by month, prior plan, and time to churn.







🧪 Testing Business Hypotheses

Hypothesis					Method

Churn is higher for monthly vs annual plans - 	Plan-wise churn rate analysis

Users downgrade before churn		    -   Sequence of plan transitions

Pro monthly users contribute max revenue    -   Revenue per plan





**🛣️ Customer Journeys to Analyze**

**Free Trial → Basic Monthly → Churn**

**Free Trial → Pro Monthly → Pro Annual**

**Basic → Pro → Downgrade → Churn**

**Trial Skip → Direct Pro Annual**





❓ Suggested Exit Survey Questions

What was your primary reason for leaving?

Did the pricing match the value you received?

What could we improve in our content or app?

Would you consider returning in the future?

Were there technical or payment issues?







🧩 How Can Churn Be Reduced?

Offer incentives before predicted churn month

Detect and intervene in downgrade patterns

Trigger in-app feedback loops before cancellation

A/B test different retention strategies



📊 Visualization Placeholder

Dashboards to be added in /dashboards/ folder:

revenue\_dashboard.pbix or .twbx

churn\_insights\_dashboard.ipynb

Visuals for monthly growth, retention curves, and upgrade/downgrade flows







