-- ========================================================
-- PROJECT: Revenue Leakage & Delinquency Tracking Pipeline
-- SCRIPT: 01_Architecture_Setup
-- ========================================================

-- Set the working database

USE utility_billing_db;

CREATE TABLE client_master(
	disrict INT,
    client_id VARCHAR(50),
    client_catg INT,
    region INT,
    creation_date VARCHAR(20),
    target FLOAT
);

-- Creating Invoice-master table
	CREATE TABLE invoice_master (
		client_id VARCHAR(50),
        invoice_date VARCHAR(50),
        tariff_type INT,
        counter_number INT,
        counter_statue VARCHAR(5),
        counter_code INT,
        reading_remarque INT,
        counter_coefficient INT,
        consommation_level_1 INT,
        consommation_level_2 INT,
        consommation_level_3 INT,
        consommation_level_4 INT,
        old_index INT,
		new_index INT,
        months_number INT,
		counter_type VARCHAR(10)
    );

