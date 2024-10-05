-- TP4: Roles and Privileges

-- 1. Create ROLE_TP3
CREATE ROLE ROLE_TP3;

GRANT CREATE SESSION, CREATE TABLE, CREATE ROLE, 
      CREATE PROCEDURE, CREATE ANY PROCEDURE TO ROLE_TP3;

GRANT SELECT ON HR.EMPLOYEES TO ROLE_TP3;
GRANT SELECT ON HR.DEPARTMENTS TO ROLE_TP3;

-- 2. Grant ROLE_TP3 to TP3
GRANT ROLE_TP3 TO TP3;

-- 3. Create table Etudiants (as TP3)
-- Connect as TP3 first
CREATE TABLE Etudiants (
    Matricule NUMBER PRIMARY KEY,
    nom VARCHAR2(50),
    prenom VARCHAR2(50),
    tel VARCHAR2(15),
    dateNaissance DATE
);

-- 4. Create user TP3_2
CREATE USER TP3_2 IDENTIFIED BY password
QUOTA 5M ON USERS
PROFILE profil_tp3;

-- 5. Grant ROLE_TP3 to TP3_2
GRANT ROLE_TP3 TO TP3_2;

-- 6. Grant select and insert on Etudiants to TP3_2
GRANT SELECT, INSERT ON TP3.Etudiants TO TP3_2;

-- 7. Procedure to display system privileges for a user
CREATE OR REPLACE PROCEDURE display_user_sys_privs(p_username IN VARCHAR2) IS
BEGIN
    FOR rec IN (SELECT privilege
                FROM dba_sys_privs
                WHERE grantee = UPPER(p_username)
                UNION
                SELECT privilege
                FROM dba_role_privs rp
                JOIN role_sys_privs sp ON rp.granted_role = sp.role
                WHERE rp.grantee = UPPER(p_username)) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.privilege);
    END LOOP;
END;
/

-- Test the procedure
EXEC display_user_sys_privs('TP3');

-- 8. Procedure to display object privileges for a role
CREATE OR REPLACE PROCEDURE display_role_obj_privs(p_role IN VARCHAR2) IS
BEGIN
    FOR rec IN (SELECT table_name, privilege
                FROM role_tab_privs
                WHERE role = UPPER(p_role)) LOOP
        DBMS_OUTPUT.PUT_LINE('Table: ' || rec.table_name || ', Privilege: ' || rec.privilege);
    END LOOP;
END;
/

-- Test the procedure
EXEC display_role_obj_privs('ROLE_TP3');