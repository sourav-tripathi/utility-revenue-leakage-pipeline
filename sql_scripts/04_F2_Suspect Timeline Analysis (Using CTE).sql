
-- SCRIPT: Suspect Timeline Analysis (Using CTE)
-- ========================================================

USE utility_billing_db;

-- 1. Create a temporary invisible table called 'SuspectAccount'
WITH Suspect_Account AS (
	SELECT a.client_id
    FROM client_master AS a
    INNER JOIN invoice_master AS i 
    ON a.client_id = i.client_id
    WHERE a.region = 101 AND i.consommation_level_1 =0
    LIMIT 1
)
    
-- 2. Use that temporary table to pull their entire billing history chronologically
SELECT i.client_id,
	   i.clean_invoice_date,
       i.consommation_level_1 AS electricity_used,
       i.counter_statue AS meter_status
FROM invoice_master AS i 
INNER JOIN Suspect_Account AS s
 ON i.client_id = s.client_id
ORDER by i.clean_invoice_date ASC;


