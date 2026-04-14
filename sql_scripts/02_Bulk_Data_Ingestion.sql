LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/client_train.csv'
INTO TABLE client_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- LOADING invoice_master table . Error in code - /n - \n
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_train.csv'
INTO TABLE invoice_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '/n'
IGNORE 1 ROWS;

TRUNCATE TABLE invoice_master;

-- Fixed to \n but still error as counter_number has higer range value , so need to convert from INT to VARCHAR 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_train.csv'
INTO TABLE invoice_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Changing DDL of counter_number to VARCHAR
 ALTER TABLE invoice_master MODIFY COLUMN counter_number VARCHAR(50);
 
 TRUNCATE TABLE invoice_master;
 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_train.csv'
INTO TABLE invoice_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

TRUNCATE TABLE invoice_master;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_train.csv'
INTO TABLE invoice_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


--  Error Code: 1406. Data too long for column 'counter_statue' at row 2773074	52.203 sec
ALTER TABLE invoice_master MODIFY COLUMN counter_statue VARCHAR(50);

TRUNCATE TABLE invoice_master;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_train.csv'
INTO TABLE invoice_master
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
