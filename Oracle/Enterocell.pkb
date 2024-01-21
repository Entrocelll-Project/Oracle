create or replace PACKAGE BODY ENTEROCELL IS
    FUNCTION login (P_MSISDN IN SUBSCRIBER.MSISDN%TYPE, P_PASSWORD IN SUBSCRIBER.PASSWORD%TYPE) RETURN NUMBER
    AS
        v_match_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_match_count FROM SUBSCRIBER WHERE MSISDN = P_MSISDN AND password = P_PASSWORD;
        
        IF v_match_count = 0 THEN
            RETURN 0;
        ELSIF v_match_count >= 1 THEN
            RETURN 1;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN 
            RETURN 0;
    END login; 

    FUNCTION get_subscriber_id RETURN NUMBER 
    AS
        u_id NUMBER;
    BEGIN 
        u_id := SUBSC_ID_SEQUENCE.nextval;
        RETURN u_id;
    END get_subscriber_id;

    FUNCTION get_user_package(p_msisdn subscriber.msisdn%type) RETURN package.package_name%type
    AS
        v_package_name package.package_name%type;
    BEGIN
        SELECT package.package_name INTO v_package_name FROM SUBSCRIBER INNER JOIN BALANCE ON subscriber.subsc_id = balance.subsc_id
                                                    INNER JOIN PACKAGE ON balance.package_id = package.package_id WHERE subscriber.msisdn = p_msisdn;
        RETURN v_package_name;
    END;

    FUNCTION get_remaining_voice(p_msisdn subscriber.msisdn%type) RETURN NUMBER
    AS
        remaining_voice number;
    BEGIN
        SELECT (package.amount_voice - balance.bal_lvl_voice) INTO remaining_voice FROM SUBSCRIBER INNER JOIN BALANCE ON subscriber.subsc_id = balance.subsc_id
                                                    INNER JOIN PACKAGE ON balance.package_id = package.package_id WHERE subscriber.msisdn = p_msisdn;
        RETURN remaining_voice;
    END;

    FUNCTION get_remaining_data(p_msisdn subscriber.msisdn%type) RETURN NUMBER
    AS
        remaining_data number;
    BEGIN
        SELECT (package.amount_data - balance.bal_lvl_data) INTO remaining_data FROM SUBSCRIBER INNER JOIN BALANCE ON subscriber.subsc_id = balance.subsc_id
                                                    INNER JOIN PACKAGE ON balance.package_id = package.package_id WHERE subscriber.msisdn = p_msisdn;
        RETURN remaining_data;
    END;

    FUNCTION get_remaining_sms(p_msisdn subscriber.msisdn%type) RETURN NUMBER
    AS
        remaining_sms number;
    BEGIN
        SELECT (package.amount_sms - balance.bal_lvl_sms) INTO remaining_sms FROM SUBSCRIBER INNER JOIN BALANCE ON subscriber.subsc_id = balance.subsc_id
                                                    INNER JOIN PACKAGE ON balance.package_id = package.package_id WHERE subscriber.msisdn = p_msisdn;
        RETURN remaining_sms;
    END;

    FUNCTION forget_password (P_EMAIL IN SUBSCRIBER.EMAIL%TYPE, P_MSISDN IN SUBSCRIBER.MSISDN%TYPE) RETURN NVARCHAR2
    AS
        P_PASSWORD subscriber.PASSWORD%TYPE;
    BEGIN
        SELECT password INTO P_PASSWORD FROM subscriber WHERE email = P_EMAIL AND MSISDN = P_MSISDN;

        IF P_PASSWORD IS NULL THEN
            RETURN 'Invalid phone number';
        ELSE
            RETURN P_PASSWORD;
        END IF;
    END forget_password;

    PROCEDURE create_subscriber(S_SUBSC_ID IN SUBSCRIBER.SUBSC_ID%TYPE, S_MSISDN IN SUBSCRIBER.MSISDN%TYPE, S_NAME IN SUBSCRIBER.NAME%TYPE, S_SURNAME IN SUBSCRIBER.SURNAME%TYPE, 
                                S_EMAIL IN SUBSCRIBER.EMAIL%TYPE, S_PASSWORD IN SUBSCRIBER.PASSWORD%TYPE,
                                P_PACKAGE_ID IN PACKAGE.PACKAGE_ID%TYPE) AS
        v_package_id NUMBER;
        v_package_name NVARCHAR2(200);
    BEGIN
        SELECT package_id, package_name INTO v_package_id, v_package_name FROM package WHERE package_id = P_PACKAGE_ID; 

        INSERT INTO SUBSCRIBER (subsc_id, msisdn, name, surname, email, password, sdate, status) 
        VALUES (S_SUBSC_ID, S_MSISDN, S_NAME, S_SURNAME, S_EMAIL, S_PASSWORD, SYSDATE, 'ACTIVE');

        INSERT INTO BALANCE (subsc_id, package_id, bal_lvl_voice, bal_lvl_sms, bal_lvl_data, sdate, edate) 
        VALUES (S_SUBSC_ID, v_package_id, NULL, NULL, NULL, SYSDATE, SYSDATE);
    END create_subscriber;

    PROCEDURE insert_usage_record (p_msisdn IN USAGE_RECORD.MSISDN%TYPE, p_usage_date IN USAGE_RECORD.USAGE_DATE%TYPE, p_voice_duration IN USAGE_RECORD.VOICE_DURATION%TYPE,
                                  p_sms_count IN USAGE_RECORD.SMS_COUNT%TYPE, p_data_usage IN USAGE_RECORD.DATA_USAGE%TYPE, p_internet_page IN USAGE_RECORD.INTERNET_PAGE%TYPE, p_destination IN USAGE_RECORD.DESTINATION%TYPE) 
    AS
    BEGIN
        INSERT INTO USAGE_RECORD (USAGE_RECORD_ID, MSISDN, USAGE_DATE, VOICE_DURATION, SMS_COUNT, DATA_USAGE, INTERNET_PAGE, DESTINATION) 
        VALUES (usage_record_id_sequence.NEXTVAL, p_msisdn, p_usage_date, p_voice_duration, p_sms_count, p_data_usage, p_internet_page, p_destination);
        COMMIT;
    END insert_usage_record;
    PROCEDURE update_voice(p_subsc_id in subscriber.subsc_id%type, p_msisdn in subscriber.msisdn%type, amount in number, p_price in balance.price%type) IS
    BEGIN
    COMMIT;
        MERGE INTO BALANCE b
            USING (
                SELECT subsc_id FROM subscriber WHERE MSISDN = p_msisdn AND subsc_id = p_subsc_id 
            )s
            ON (b.SUBSC_ID = s.SUBSC_ID)
        WHEN MATCHED THEN
        UPDATE SET b.price = b.price + p_price, b.bal_lvl_voice = b.bal_lvl_voice + amount ;
        COMMIT;
    END;

    PROCEDURE update_data(p_subsc_id in subscriber.subsc_id%type, p_msisdn in subscriber.msisdn%type, amount in number, p_price in balance.price%type) IS
    BEGIN
    COMMIT;
        MERGE INTO BALANCE b
            USING (
                SELECT subsc_id FROM subscriber WHERE MSISDN = p_msisdn AND subsc_id = p_subsc_id 
            )s
            ON (b.SUBSC_ID = s.SUBSC_ID)
        WHEN MATCHED THEN
        UPDATE SET b.price = b.price + p_price, b.bal_lvl_data = b.bal_lvl_data + amount ;
        COMMIT;
    END;

    PROCEDURE update_sms(p_subsc_id in subscriber.subsc_id%type, p_msisdn in subscriber.msisdn%type, amount in number, p_price in balance.price%type) IS
    BEGIN
    COMMIT;
        MERGE INTO BALANCE b
            USING (
                SELECT subsc_id FROM subscriber WHERE MSISDN = p_msisdn AND subsc_id = p_subsc_id 
            )s
            ON (b.SUBSC_ID = s.SUBSC_ID)
        WHEN MATCHED THEN
        UPDATE SET b.price = b.price + p_price, b.bal_lvl_sms = b.bal_lvl_sms + amount ;
        COMMIT;
    END;

END ENTEROCELL;