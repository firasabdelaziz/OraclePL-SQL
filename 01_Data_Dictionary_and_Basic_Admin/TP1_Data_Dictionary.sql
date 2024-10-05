-- TP1: Data Dictionary and Basic Administration

-- 1. List of data dictionary views sorted by name
SELECT view_name
FROM dict
ORDER BY view_name;

-- 2. List of users created on the server with creation date
SELECT username, created
FROM dba_users
ORDER BY created;

-- 3. List of connected users on the current instance
SELECT username, machine, program
FROM v$session
WHERE username IS NOT NULL;

-- 4. Determine total size of SGA
SELECT sum(value) as total_sga_size
FROM v$sga;

-- 5. List objects, their type, creation date, and last modification date for HR user
SELECT object_name, object_type, created, last_ddl_time
FROM all_objects
WHERE owner = 'HR'
ORDER BY object_type, object_name;

-- 6. Display table names on which HR has rights
SELECT table_name
FROM all_tables
WHERE owner = 'HR';

-- 7. Procedure to display names of HR's proprietary tables
CREATE OR REPLACE PROCEDURE show_hr_tables IS
BEGIN
    FOR rec IN (SELECT table_name FROM all_tables WHERE owner = 'HR') LOOP
        DBMS_OUTPUT.PUT_LINE(rec.table_name);
    END LOOP;
END;
/

-- 8. Display total number of tables created on the server
SELECT COUNT(*) as total_tables
FROM dba_tables;

-- 9. Display total number of tables created by HR user
SELECT COUNT(*) as hr_tables
FROM dba_tables
WHERE owner = 'HR';

-- 10. Function to return the number of objects for a given user
CREATE OR REPLACE FUNCTION count_user_objects(p_username IN VARCHAR2) 
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM dba_objects
    WHERE owner = UPPER(p_username);
    
    RETURN v_count;
END;
/

-- 11. Procedure to list tables for a given user
CREATE OR REPLACE PROCEDURE list_user_tables(p_username IN VARCHAR2) IS
BEGIN
    FOR rec IN (SELECT table_name 
                FROM dba_tables 
                WHERE owner = UPPER(p_username)) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.table_name);
    END LOOP;
END;
/

-- Test the procedure with HR user
EXEC list_user_tables('HR');