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
