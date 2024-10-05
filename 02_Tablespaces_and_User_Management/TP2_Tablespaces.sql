-- TP2: Tablespaces and User Management

-- 1. Create tablespace TBL01
CREATE TABLESPACE TBL01
DATAFILE 'fd01tbl01.dbf' SIZE 6M,
         'fd02tbl01.dbf' SIZE 4M;

-- 2. Make TBL01 the default tablespace
ALTER DATABASE DEFAULT TABLESPACE TBL01;

-- 3. Create tablespace TBL02
CREATE TABLESPACE TBL02
DATAFILE 'fd01tbl02.dbf' SIZE 10M,
         'fd02tbl02.dbf' SIZE 10M,
         'fd0xbl02.dbf' SIZE 5M;

-- 4. Add datafile to TBL01
ALTER TABLESPACE TBL01
ADD DATAFILE 'fd02tbl01.dbf' SIZE 20M;

-- 5. Rename datafile in TBL02
ALTER TABLESPACE TBL02
RENAME DATAFILE 'fd0xbl02.dbf' TO 'fd03bl02.dbf';

-- 6. Display list of tablespace names
SELECT tablespace_name
FROM dba_tablespaces;

-- 7. PL/SQL block to display tablespace names and number of files
DECLARE
    CURSOR c_tablespaces IS
        SELECT tablespace_name, COUNT(*) as file_count
        FROM dba_data_files
        GROUP BY tablespace_name;
BEGIN
    FOR rec IN c_tablespaces LOOP
        DBMS_OUTPUT.PUT_LINE('Tablespace: ' || rec.tablespace_name || 
                             ', Files: ' || rec.file_count);
    END LOOP;
END;
/

-- 8. Add autoextensible file to TBL01
ALTER TABLESPACE TBL01
ADD DATAFILE 'fd04tlb01.dbf' 
    SIZE 2M 
    AUTOEXTEND ON 
    NEXT 1M 
    MAXSIZE 4M;

-- 9. Create temporary tablespace
CREATE TEMPORARY TABLESPACE MonTemp
TEMPFILE 'montemp01.dbf' SIZE 5M;

ALTER DATABASE DEFAULT TEMPORARY TABLESPACE MonTemp;

-- 10. Function to count temporary tablespaces
CREATE OR REPLACE FUNCTION FN_NBR_TAB_TEMP
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM dba_tablespaces
    WHERE contents = 'TEMPORARY';
    
    RETURN v_count;
END;
/

-- 11. Create user TD3
CREATE USER TD3 IDENTIFIED BY password
DEFAULT TABLESPACE TBL01
TEMPORARY TABLESPACE MonTemp;

-- 12. Drop tablespace TBL01
DROP TABLESPACE TBL01 INCLUDING CONTENTS AND DATAFILES;

-- 13. Procedure to display tablespace details
CREATE OR REPLACE PROCEDURE PS_DETAILS_TAB IS
BEGIN
    FOR rec IN (SELECT tablespace_name, 
                       SUM(bytes)/1024/1024 as total_size_mb,
                       SUM(DECODE(autoextensible, 'YES', maxbytes, bytes))/1024/1024 as max_size_mb
                FROM dba_data_files
                GROUP BY tablespace_name) LOOP
        DBMS_OUTPUT.PUT_LINE('Tablespace: ' || rec.tablespace_name || 
                             ', Total Size (MB): ' || rec.total_size_mb ||
                             ', Max Size (MB): ' || rec.max_size_mb);
    END LOOP;
END;
/

-- Execute the procedure
EXEC PS_DETAILS_TAB;