# Enterprise Runbook: Bulk Data Ingestion & Security Management

**Objective:** Load 135,000+ customers and 4.5M+ billing records into MySQL.
**Problem:** The standard GUI Import Wizard is inefficient for large datasets, risking UI freeze.
**Solution:** Implement programmatic `LOAD DATA INFILE` for rapid memory injection, requiring the bypassing of Role-Based Access Control (RBAC) and internal server firewalls.



### Phase 1: Environment Cleanup
Ensure the landing table is entirely empty to prevent duplicate records or corrupted partial loads.
```sql
USE utility_billing_db;
TRUNCATE TABLE client_master;



Phase 2: Role-Based Access Control (RBAC) Override
Error Encountered: Error 1045: Access denied for user 'pipeline_admin'
Resolution: Logged in as Global Administrator (root) to grant the global FILE privilege, then refreshed the user session.

GRANT FILE ON *.* TO 'pipeline_admin'@'localhost';
FLUSH PRIVILEGES;



Phase 3: Navigating the Internal Firewall (secure-file-priv)
Error Encountered: Error 1290: The MySQL server is running with the --secure-file-priv option
Resolution: Queried the server to locate its designated, highly secure upload directory and staged the raw CSV files there.

SHOW VARIABLES LIKE 'secure_file_priv';




Phase 4: Pipeline Execution
Result: 135,493 rows ingested successfully in ~2.59 seconds.

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/client_train.csv'
INTO TABLE client_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;




Phase 5: Handling Dirty Legacy Data (Data Type Limits)
Error Encountered: Error 1264: Out of range value and Error 1406: Data too long
Resolution: Performed live table surgical alterations using ALTER TABLE to expand the column limits without destroying the table structure.

ALTER TABLE invoice_master MODIFY COLUMN counter_number VARCHAR(50);
ALTER TABLE invoice_master MODIFY COLUMN counter_statue VARCHAR(50);




Phase 6: Managing Massive Payloads & Session Timeouts
Error Encountered: Error 2013: Lost connection to MySQL server during query
Resolution: Reconfigured the DBMS connection read timeout interval from 30 seconds to 600 seconds to allow the engine sufficient time to process massive bulk inserts.

Final Result: 4,476,749 billing records successfully ingested into the database vault in 40.7 seconds.

