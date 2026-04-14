# Enterprise Runbook: Advanced Analytics & Fraud Detection

**Objective:** Isolate specific customer accounts exhibiting fraudulent "meter bypass" behavior (sudden drops to 0 usage).
**Problem:** Standard `WHERE usage = 0` queries create False Positives by flagging vacant properties. To find actual anomalies, we must compare a customer's current bill to their historical bills. 
**Solution:** Utilize a Common Table Expression (CTE) combined with a `LAG()` Window Function to perform chronological row-over-row comparisons.

### Phase 1: The Automated Anomaly Detection Pipeline

```sql
WITH UsageHistory AS (
    SELECT 
        i.client_id,
        i.clean_invoice_date,
        i.consommation_level_1 AS current_usage,
        LAG(i.consommation_level_1) OVER (
            PARTITION BY i.client_id 
            ORDER BY i.clean_invoice_date ASC
        ) AS previous_usage
    FROM invoice_master AS i
    INNER JOIN client_master AS c 
        ON i.client_id = c.client_id
    WHERE c.region = 101
)
SELECT 
    client_id,
    clean_invoice_date AS date_of_drop,
    previous_usage,
    current_usage,
    (previous_usage - current_usage) AS usage_drop_amount
FROM UsageHistory
WHERE current_usage = 0 
  AND previous_usage > 500  
ORDER BY usage_drop_amount DESC;