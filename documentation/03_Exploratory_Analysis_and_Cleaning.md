# Enterprise Runbook: Exploratory Data Analysis & ELT Transformation

**Objective:** Perform initial diagnostic queries to locate revenue leakage and standardize messy legacy data formats to enable time-series analysis.
**Phase:** Post-Ingestion / Pre-Advanced Analytics

### Phase 1: Ghost Account Detection (Billing System Audit)
**Hypothesis:** Revenue is leaking because the automated system is failing to generate invoices for active customers.
**Action:** Executed a `LEFT JOIN` to find customers in the directory who have absolutely no matching records in the billing ledger.

```sql
USE utility_billing_db;

-- Isolate customers existing in the master directory but missing from the invoice ledger
SELECT 
    c.client_id, 
    c.region, 
    c.creation_date
FROM client_master c
LEFT JOIN invoice_master i 
    ON c.client_id = i.client_id
WHERE i.client_id IS NULL;