-- ========================================================
-- SCRIPT: Creating the BI Reporting Layer (Data Mart)
-- ========================================================

USE utility_billing_db;

-- 1. Create a dedicated table just for Power BI to read
CREATE TABLE bi_fraud_mart AS
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
  AND previous_usage > 500;