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
