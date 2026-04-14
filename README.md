# ⚡ Enterprise Data Pipeline: Utility Revenue Leakage & Fraud Detection

**Role:** Lead Data Engineer / BI Analyst  
**Tech Stack:** MySQL (Database Engine), Power BI (Visualization), Power Query (Data Cleaning)  
**Dataset:** 4.5 Million Legacy Utility Invoices, ~135k Client Records  

---

## 📊 Executive Summary
The business was experiencing unexplained revenue leakage. The objective was to ingest, clean, and analyze 4.5 million legacy billing records to identify the root cause. Through Exploratory Data Analysis (EDA) and advanced Window Functions, I proved the leakage was not a system failure, but localized hardware tampering (meter bypassing). 

I successfully isolated **27,051 high-probability fraudulent accounts** and engineered a dedicated Data Mart to feed a live Executive Power BI Dashboard.

---

## 🏗️ Phase 1: Ingestion & Security Architecture
* **The Problem:** Legacy data existed in massive, flat CSV files, making enterprise analysis impossible.
* **The Action:** Engineered a relational database (`utility_billing_db`) and executed a bulk data load of 4.5 million records into two primary tables (`client_master` and `invoice_master`).

> 🛡️ **Security Highlight:** I enforced the Principle of Least Privilege (PoLP). Bulk data insertion was handled by a dedicated `pipeline_admin` account, ensuring that end-user reporting tools do not have global `root` access to delete or alter financial records.

---

## 🔍 Phase 2: Exploratory Data Analysis (Diagnostic)
* **The Problem:** We needed to pinpoint where the money was disappearing. Was the automated billing system failing, or were the meters reading incorrectly?

### Step 2A: The "Ghost Account" Audit
**The Hypothesis:** Customers exist in the directory but are not generating invoices.

```sql
SELECT c.client_id
FROM client_master c
LEFT JOIN invoice_master i ON c.client_id = i.client_id
WHERE i.client_id IS NULL;
Result: 0 rows returned.

Business Insight: The automated invoice generator is working perfectly. The leak is happening at the meter level.

Step 2B: Regional Hotspot Detection
The Hypothesis: If bills are generating, they must be generating for $0.00 (Zero Usage).

SQL
SELECT c.region, COUNT(i.client_id) AS zero_usage_bills
FROM client_master c
INNER JOIN invoice_master i ON c.client_id = i.client_id
WHERE i.consommation_level_1 = 0
GROUP BY c.region
ORDER BY zero_usage_bills DESC;
Result: Region 101 was identified as the critical hotspot with 220,710 zero-usage bills.

🛠️ Phase 3: ELT Data Transformation
The Problem: Legacy dates in the invoice ledger were stored as VARCHAR with mixed formats (%d/%m/%Y and %Y-%m-%d). We cannot perform chronological anomaly detection on text strings.

The Action: Bypassed the database safety lock (SET SQL_SAFE_UPDATES = 0), created a strict DATE column, and executed a dynamic CASE WHEN statement to standardize the entire ledger.

SQL
UPDATE invoice_master
SET clean_invoice_date = CASE 
    WHEN invoice_date LIKE '%/%' THEN STR_TO_DATE(invoice_date, '%d/%m/%Y')
    WHEN invoice_date LIKE '%-%' THEN STR_TO_DATE(invoice_date, '%Y-%m-%d')
    ELSE NULL 
END;
Result: 4.47 million rows scrubbed and chronologically aligned in ~121 seconds.

🚨 Phase 4: Advanced Analytics (The Fraud Trap)
The Problem: Standard SQL evaluates data one row at a time. Searching for usage = 0 creates massive "False Positives" because it flags naturally vacant houses. We needed the database to possess "memory" to compare a customer's current bill against their historical bills.

The Action: Engineered a Common Table Expression (CTE) utilizing the LAG() Window Function.

SQL
WITH UsageHistory AS (
    SELECT 
        i.client_id, i.clean_invoice_date, i.consommation_level_1 AS current_usage,
        LAG(i.consommation_level_1) OVER (
            PARTITION BY i.client_id 
            ORDER BY i.clean_invoice_date ASC
        ) AS previous_usage
    FROM invoice_master i
    INNER JOIN client_master c ON i.client_id = c.client_id
)
SELECT * FROM UsageHistory
WHERE current_usage = 0 AND previous_usage > 500;
🧠 The Logic Behind the Filter: > * Why current_usage = 0? We are hunting for meters that have stopped recording.

Why previous_usage > 500? If a customer drops from 20 units to 0, they likely went on vacation. However, 500+ units indicates a fully active household. A sudden, violent drop from massive consumption to absolute zero is the exact digital fingerprint of a customer physically bypassing the meter.

Result: Scanned 4.5 million chronological records and isolated exactly 27,051 high-probability fraud accounts in ~42 seconds.

📈 Phase 5: The BI Reporting Layer (Data Mart)
The Problem: Connecting a Business Intelligence tool (Power BI) directly to a complex Window Function calculation causes severe performance bottlenecks and memory timeouts during live filtering.

The Action: Offloaded the heavy compute back to the database engine. Wrapped the LAG() CTE inside a CREATE TABLE bi_fraud_mart AS statement.

Business Insight: By materializing the view into a dedicated "Data Mart", Power BI now queries a lightweight, pre-calculated table of 27,000 rows instead of crunching 4.5 million rows on the fly, resulting in instant dashboard rendering.
