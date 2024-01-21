create or replace PACKAGE        ENTEROCELL IS
    FUNCTION login (P_MSISDN IN SUBSCRIBER.MSISDN%TYPE, P_PASSWORD IN SUBSCRIBER.PASSWORD%TYPE) RETURN NUMBER;
    FUNCTION get_subscriber_id RETURN NUMBER;
    FUNCTION get_user_package (P_MSISDN SUBSCRIBER.MSISDN%TYPE) RETURN PACKAGE.PACKAGE_NAME%TYPE;
    FUNCTION get_remaining_voice (P_MSISDN SUBSCRIBER.MSISDN%TYPE) RETURN NUMBER;
    FUNCTION get_remaining_data (P_MSISDN SUBSCRIBER.MSISDN%TYPE) RETURN NUMBER;
    FUNCTION get_remaining_sms (P_MSISDN SUBSCRIBER.MSISDN%TYPE) RETURN NUMBER;

    FUNCTION forget_password(P_EMAIL IN SUBSCRIBER.EMAIL%TYPE,P_MSISDN IN SUBSCRIBER.MSISDN%TYPE) RETURN NVARCHAR2;
    
    PROCEDURE create_subscriber(S_SUBSC_ID IN SUBSCRIBER.SUBSC_ID%TYPE,S_MSISDN IN SUBSCRIBER.MSISDN%TYPE, S_NAME IN SUBSCRIBER.NAME%TYPE, S_SURNAME IN SUBSCRIBER.SURNAME%TYPE, 
                                S_EMAIL IN SUBSCRIBER.EMAIL%TYPE, S_PASSWORD IN SUBSCRIBER.PASSWORD%TYPE,
                                P_PACKAGE_ID IN PACKAGE.PACKAGE_ID%TYPE);
   PROCEDURE insert_usage_record (P_MSISDN IN USAGE_RECORD.MSISDN%TYPE,P_USAGE_DATE IN USAGE_RECORD.USAGE_DATE%TYPE,P_VOICE_DURATION IN USAGE_RECORD.VOICE_DURATION%TYPE,
    P_SMS_COUNT IN USAGE_RECORD.SMS_COUNT%TYPE,P_DATA_USAGE IN USAGE_RECORD.DATA_USAGE%TYPE,P_INTERNET_PAGE IN USAGE_RECORD.INTERNET_PAGE%TYPE,P_DESTINATION IN USAGE_RECORD.DESTINATION%TYPE);
    
    PROCEDURE update_voice(p_subsc_id in subscriber.subsc_id%type, p_msisdn in subscriber.msisdn%type, amount in number, p_price in balance.price%type);
    PROCEDURE update_data(p_subsc_id in subscriber.subsc_id%type, p_msisdn in subscriber.msisdn%type, amount in number, p_price in balance.price%type);
    PROCEDURE update_sms(p_subsc_id in subscriber.subsc_id%type, p_msisdn in subscriber.msisdn%type, amount in number, p_price in balance.price%type);
END ENTEROCELL;