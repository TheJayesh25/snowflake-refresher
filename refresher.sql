-- Select roles & warehouse
USE ROLE ACCOUNTADMIN;

USE WAREHOUSE COMPUTE_WH;

-- Create a database and schema within the database
CREATE OR REPLACE DATABASE my_database;

USE DATABASE my_database;

CREATE OR REPLACE SCHEMA my_schema;

USE SCHEMA my_database.my_schema;

-- Create a permanent table
CREATE OR REPLACE TABLE t1 (
tid INT,
tname STRING
);

-- Create a transient table
CREATE OR REPLACE TRANSIENT TABLE t2 (
tid INT,
tname STRING
);

-- Create a temporary table
CREATE OR REPLACE TEMPORARY TABLE t3 (
tid INT,
tname STRING
);

SHOW TABLES;

-- Alter retention times of all the tables to see how their behavior varies from each other
ALTER TABLE t1 SET DATA_RETENTION_TIME_IN_DAYS = 3; -- This query allows us to update the data_retention_time_in_days for the permanent table t1 since the max data retention time of such tables is 90 days

-- ALTER TABLE t2 SET DATA_RETENTION_TIME_IN_DAYS = 3; -- max data retention time of transient tables is 1 day so this query does not run

-- ALTER TABLE t3 SET DATA_RETENTION_TIME_IN_DAYS = 3; -- max data retention time of temporary tables is 1 day so this query does not run

SHOW TABLES;

-- Drop unused tables for this practice
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t3;


-- Create an Employee Table
CREATE OR REPLACE TABLE employees (
    emp_id INTEGER,
    emp_name VARCHAR (50),
    dept VARCHAR(50),
    salary INTEGER
);

-- Inserting data into the Employee table
EXECUTE IMMEDIATE $$
BEGIN
    -- Check if the table exists in the current database/schema context
    IF (EXISTS (
        SELECT 1 
        FROM information_schema.tables 
        WHERE table_schema = CURRENT_SCHEMA() 
          AND table_name = 'EMPLOYEES' -- Must be uppercase
    )) THEN
        -- Run the insert only if the table is found
        INSERT INTO EMPLOYEES (emp_id, emp_name, dept, salary)
        VALUES (101, 'John Doe', 'Admin', 55000),
               (102, 'Serene Ferns', 'Sales', 59000),
               (104, 'Chico Conceicao', 'Data-Ops', 91000),
               (105, 'Jannet Queen', 'HR', 63000),
               (108, 'Aditya Rathod', 'Data-Ops', 80000),
               (113, 'Hayato Suzuki', 'IT', 67000),
               (113, 'Maithili Singh', 'Marketing', 655000);
        RETURN 'Success: Table existed and data was inserted.';
    ELSE
        -- Silently catch the miss instead of failing
        RETURN 'Skipped: Table does not exist.';
    END IF;
END $$;


-- Alternate simple method to insert data into table
-- INSERT INTO employees (emp_id, emp_name, dept, salary)
-- VALUES (101, 'John Doe', 'Admin', 55000),
--        (102, 'Serene Ferns', 'Sales', 59000),
--        (104, 'Chico Conceicao', 'Data-Ops', 91000),
--        (105, 'Jannet Queen', 'HR', 63000),
--        (108, 'Aditya Rathod', 'Data-Ops', 80000),
--        (113, 'Hayato Suzuki', 'IT', 67000),
--        (113, 'Maithili Singh', 'Marketing', 655000);


-- Select and verify inserted data
SELECT * FROM employees;


-- Creating a view called data_ops_employees that only includes the employees from Data-Ops Department
CREATE OR REPLACE VIEW data_ops_employees AS
SELECT emp_id, emp_name, salary
FROM EMPLOYEES
WHERE dept = 'Data-Ops';

-- Select data from the data_ops_employees view
SELECT * FROM data_ops_employees


-- Creating a SECURE view called admin_employees that only includes the employees from Admin Department
CREATE OR REPLACE SECURE VIEW admin_employees AS
SELECT emp_id, emp_name, salary
FROM EMPLOYEES
WHERE dept = 'Admin';

-- Select data from the admin_employees view
SELECT * FROM admin_employees


-- Creating a materialized view called hr_employees that only includes the employees from HR Department
CREATE OR REPLACE MATERIALIZED VIEW mat_hr_employees AS
SELECT emp_id, emp_name, salary
FROM EMPLOYEES
WHERE dept = 'HR';

-- Select data from the hr_employees view
SELECT * FROM mat_hr_employees




-- Creating a view that aggregates salaries by Department
CREATE OR REPLACE VIEW salary_by_dept AS
SELECT dept, ROUND(AVG(salary),0) as average_salary
FROM EMPLOYEES
GROUP BY dept;

-- Select data from the salary_by_dept view
SELECT * FROM salary_by_dept


-- Creating a materialized view that aggregates salaries by Department
CREATE OR REPLACE MATERIALIZED VIEW mat_salary_by_dept AS
SELECT dept, ROUND(AVG(salary)) as average_salary
FROM EMPLOYEES
GROUP BY dept;

-- Select data from the mat_salary_by_dept view
SELECT * FROM mat_salary_by_dept;


-- NOTE: A normal view is a virtual table that stores only the sql definition, runs its query dynamically, scans the tables for the records and returns the output every time vs a materialized view does not scan the table, it pre-computes and physically stores the query results for much faster data retrieval (it is stored in the persistent storage, not temporary cache)

SHOW VIEWS;

DROP TABLE IF EXISTS my_database.my_schema.employees;

DROP VIEW IF EXISTS ADMIN_EMPLOYEES;
DROP VIEW IF EXISTS DATA_OPS_EMPLOYEES;
DROP MATERIALIZED VIEW IF EXISTS MAT_HR_EMPLOYEES;

DROP VIEW IF EXISTS SALARY_BY_DEPT;
DROP MATERIALIZED VIEW IF EXISTS MAT_SALARY_BY_DEPT;

ALTER SESSION SET USE_CACHED_RESULT = FALSE;



--==============STAGES==============
-- Create an Employee Table
CREATE OR REPLACE TABLE employees (
    emp_id INTEGER,
    emp_name VARCHAR (50),
    dept VARCHAR(50),
    salary INTEGER
);

-- Accessing Table stage
LIST @%EMPLOYEES;

-- Accessing User stage
CREATE USER tj_test;
SHOW USERS;

LIST @~;

DROP USER tj_test;

SHOW USERS;

DROP TABLE employees;

-- Creating a customer Table

CREATE OR REPLACE TABLE customer(MY_DATABASE.MY_SCHEMA.CUSTOMER_STAGE
    cust_id INT,
    cust_name VARCHAR(50),
    cust_gender STRING,
    cust_age INT
);

-- Creating a NAMED Stage
CREATE OR REPLACE STAGE CUSTOMER_STAGE;

-- Access internal stage
LIST @CUSTOMER_STAGE;

-- Truncate Customer Table
TRUNCATE TABLE CUSTOMER;

-- Loading data into CUSTOMER table
COPY INTO CUSTOMER
FROM @CUSTOMER_STAGE
file_format = (TYPE = 'CSV' SKIP_HEADER = 1);

-- View table data
SELECT *
FROM CUSTOMER
LIMIT 15;

-- UNDROP SCHEMA MY_DATABASE.MY_SCHEMA;

-- Creating Student table
CREATE OR REPLACE TABLE STUDENT (
    student_id INT,
    name VARCHAR(50),
    age INT,
    marks INT   
);

-- Create named student stage
CREATE OR REPLACE STAGE STUDENT_STAGE;

SHOW FILE FORMATS;

-- Create a CSV file format
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
TYPE = 'CSV'
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1;

-- List file formats
SHOW FILE FORMATS;

-- Load data into student table with file format
COPY INTO STUDENT
FROM @STUDENT_STAGE
file_format = (FORMAT_NAME = CSV_FORMAT);

-- Check newly loaded data
SELECT *
FROM STUDENT;

-- Create a JSON file format
CREATE FILE FORMAT JSON_FORMAT
TYPE = 'JSON';

DROP FILE FORMAT CSV_FORMAT;
DROP FILE FORMAT JSON_FORMAT;

SHOW FILE FORMATS;


DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS STUDENT;

DROP STAGE IF EXISTS CUSTOMER_STAGE;
DROP STAGE IF EXISTS STUDENT_STAGE;

ALTER SESSION SET USE_CACHED_RESULT = FALSE;


-- Testing Different ways of Bulk Data load and Continuous Data Load
CREATE OR REPLACE TABLE USER (
    id INT,
    name VARCHAR(50),
    location VARCHAR(50),
    email VARCHAR(50)
);


-- Create a storage integration with S3 and IAM role
CREATE OR REPLACE STORAGE INTEGRATION s3_int
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = <AWS_ROLE_ARN>
    STORAGE_ALLOWED_LOCATIONS = ('s3://snowflake-refresher/');


-- Describe storage integration
DESC INTEGRATION s3_int; -- To find out STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID values to update those values in Trust Relationship policy for the role in AWS


SHOW FILE FORMATS; -- CSV_FORMAT already exists to load the csv file from S3 bucket
DROP FILE FORMAT CSV_FORMAT;
DROP FILE FORMAT JSON_FORMAT;
SHOW FILE FORMATS; -- CSV_FORMAT already exists to load the csv file from S3 bucket

-- Create a file format
CREATE OR REPLACE FILE FORMAT my_csv_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1;

-- List file formats
SHOW FILE FORMATS;

-- Create an external S3 stage
CREATE OR REPLACE STAGE s3_stage
    STORAGE_INTEGRATION = s3_int
    URL = 's3://snowflake-refresher/'
    FILE_FORMAT = MY_CSV_FORMAT;

-- Validate the storage integration to see if the trust relationship is working
SELECT SYSTEM$VALIDATE_STORAGE_INTEGRATION(
    'S3_INT',
    's3://snowflake-refresher/',
    'test.txt',
    'list'
);


LIST @s3_stage;

-- SELECT CURRENT_ACCOUNT();

-- Load data into User table without file format
COPY INTO USER
FROM @s3_stage
FILE_FORMAT = (FORMAT_NAME = MY_CSV_FORMAT);

-- Check if file is loaded correctly
SELECT * FROM USER;

-- SHOW LOCKS IN ACCOUNT;

-- SELECT SYSTEM$ABORT_SESSION('60c3af72-ea05-4377-aa3d-71a262a547ba');



