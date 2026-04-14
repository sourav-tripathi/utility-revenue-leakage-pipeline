
SELECT *
FROM client_master 
LIMIT 50;

SELECT *  
FROM invoice_master 
LIMIT 100;

-- SCRIPT: Ghost Account Detection
-- ========================================================
SELECT a.client_id,
	   a.region,
       a.creation_date
FROM client_master AS a
LEFT JOIN invoice_master AS b
ON a.client_id = b.client_id
WHERE b.client_id IS NULL;

-- By returning exactly 0 rows, the database just proved our hypothesis wrong. 
-- It means that every single one of our 135,000 registered customers has at least one matching bill in the ledger


USE utility_billing_db;
-- ========================================================
-- SCRIPT: Dead Meter & Regional Fraud Detection
-- ========================================================
SELECT c.region,
	   COUNT(i.client_id) AS zero_usage_bills
FROM client_master AS c 
INNER JOIN invoice_master AS i
ON c.client_id = i.client_id
WHERE i.consommation_level_1 = 0 
GROUP BY c.region
ORDER BY zero_usage_bills DESC;


-- ========================================================
-- SCRIPT: Data Cleaning - Date Transformation
-- ========================================================

--  Change invoice_date table From VARCHAR(20) to DATE 

-- 1. Turn off the "Safety" switch so we can update millions of rows at once
SET SQL_SAFE_UPDATES =0;

ALTER TABLE invoice_master ADD COLUMN clean_invoice_date DATE;

-- Got an Error- Incorrect datetime value: '2014-03-24'  
UPDATE invoice_master
SET clean_invoice_date = STR_TO_DATE(invoice_date,'%d/%m/%y');

-- Smart Update: Handle mixed legacy date formats
UPDATE invoice_master 
SET clean_invoice_date= CASE
	WHEN invoice_date LIKE '%/%' THEN STR_TO_DATE(invoice_date, '%d/%m/%Y')
    WHEN invoice_date LIKE '%-%' THEN STR_TO_DATE(invoice_date, '%Y-%m-%d')
    ELSE NULL 
END;
  
SET SQL_SAFE_UPDATES =1;



    








    


