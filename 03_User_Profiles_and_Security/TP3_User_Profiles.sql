-- TP3: User Profiles and Security

-- 1. Create profile profil_tp3
CREATE PROFILE profil_tp3 LIMIT
    CONNECT_TIME 120
    IDLE_TIME 3
    SESSIONS_PER_USER 2
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 5/1440;

-- 2. Create user TP3
CREATE USER TP3 IDENTIFIED BY password
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 10M ON USERS
PROFILE profil_tp3;

-- 3. Verify profile attribution
SELECT username, profile
FROM dba_users
WHERE username = 'TP3';

-- 4. List created users
SELECT username
FROM dba_users
WHERE oracle_maintained = 'N'
ORDER BY username;

-- 5. Procedure to list created profiles
CREATE OR REPLACE PROCEDURE list_profiles IS
BEGIN
    FOR rec IN (SELECT DISTINCT profile 
                FROM dba_profiles 
                WHERE profile != 'DEFAULT') LOOP
        DBMS_OUTPUT.PUT_LINE(rec.profile);
    END LOOP;
END;
/

-- 6. Create password verification function
CREATE OR REPLACE FUNCTION verif_password(p_username VARCHAR2, p_password VARCHAR2)
RETURN BOOLEAN IS
BEGIN
    -- Check password length
    IF LENGTH(p_password) <= 6 THEN
        RETURN FALSE;
    END IF;
    
    -- Check for special characters
    IF NOT REGEXP_LIKE(p_password, '[?!@]') THEN
        RETURN FALSE;
    END IF;
    
    -- Check username and password are different
    IF UPPER(p_username) = UPPER(p_password) THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
/

-- 7. Modify profil_tp3 to use verif_password
ALTER PROFILE profil_tp3 
LIMIT PASSWORD_VERIFY_FUNCTION verif_password;

-- 8. Test profile with new users
-- These will fail due to password restrictions, shown for demonstration
CREATE USER testtp31 IDENTIFIED BY testtp31 PROFILE profil_tp3;
CREATE USER testtp32 IDENTIFIED BY system PROFILE profil_tp3;
CREATE USER testtp33 IDENTIFIED BY managers? PROFILE profil_tp3;

-- 9. Drop profile and check new profile for TP3
DROP PROFILE profil_tp3 CASCADE;

SELECT username, profile
FROM dba_users
WHERE username = 'TP3';