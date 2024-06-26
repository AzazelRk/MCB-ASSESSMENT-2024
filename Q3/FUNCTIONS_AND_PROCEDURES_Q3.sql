--DATE Function
CREATE OR REPLACE FUNCTION GET_VALIDATED_DATE(v_DATE IN VARCHAR2)
        RETURN DATE IS 
           v_OUTPUT VARCHAR2(50);
           v_OUTPUT_date DATE;
        BEGIN
          v_OUTPUT := v_DATE;
          v_OUTPUT := REPLACE( v_OUTPUT, '-01-','-JAN-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-02-','-FEB-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-03-','-MAR-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-04-','-APR-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-05-','-MAY-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-06-','-JUN-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-07-','-JUL-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-08-','-AUG-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-09-','-SEP-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-10-','-OCT-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-11-','-NOV-');
          v_OUTPUT := REPLACE( v_OUTPUT, '-12-','-DEC-');
          v_OUTPUT_date := TO_DATE(v_OUTPUT,'DD-MON-YYYY');
          RETURN v_OUTPUT_date;
        END;
        /
--NUMBER Function        
CREATE OR REPLACE FUNCTION GET_VALIDATED_NUMBER(v_NUMBER_VALUE IN VARCHAR2) 
        RETURN NUMBER IS
                v_OUTPUT VARCHAR2(50);
                v_OUTPUT_number NUMBER(10);
            BEGIN
                v_OUTPUT := NVL( v_NUMBER_VALUE, '0');
                v_OUTPUT := REPLACE( v_OUTPUT, 'o', '0');
                v_OUTPUT := REPLACE( v_OUTPUT, 'O', '0');
                v_OUTPUT := REPLACE( v_OUTPUT, 's', '5');
                v_OUTPUT := REPLACE( v_OUTPUT, 'S', '5');
                v_OUTPUT := REPLACE( v_OUTPUT, ' ','');
                v_OUTPUT := REPLACE( v_OUTPUT, 'i', '1');
                v_OUTPUT := REPLACE( v_OUTPUT, 'I', '1');
                v_OUTPUT := REPLACE( v_OUTPUT, ',','');
                v_OUTPUT_number := TO_NUMBER(v_OUTPUT);
                RETURN v_OUTPUT_number;
            END;
            /
            
--PHONE NUMBER Function
CREATE OR REPLACE FUNCTION GET_VALIDATED_PHONENUMBER(v_PHONE_NUMBER in VARCHAR2)
    RETURN VARCHAR2 IS
        v_OUTPUT VARCHAR2(50);
            BEGIN
               
                v_OUTPUT := NVL( v_PHONE_NUMBER,'');
               
                v_OUTPUT := REPLACE( v_OUTPUT, ' ', '');
               
                v_OUTPUT := REPLACE( v_OUTPUT, 'o', '0');
             
                v_OUTPUT := REPLACE( v_OUTPUT, 'O', '0');
             
                v_OUTPUT := REPLACE( v_OUTPUT, '.', '');
                RETURN v_OUTPUT;
            END;
            /

--Procedure for migration
CREATE OR REPLACE PROCEDURE MIGRATION_BCM AS
BEGIN

MERGE INTO XXBCM_CONTACT A
USING (

SELECT DISTINCT SUPP_CONTACT_NAME, SUPP_ADDRESS, GET_VALIDATED_PHONE_NUMBER(SUPP_CONTACT_NUMBER) AS SUPP_CONTACT_NUMBER, SUPP_EMAIL
FROM XXBXM_ORDER_MGT
) A1 ON (
A.SUPP_CONTACT_NAME = A1.SUPP_CONTACT_NAME
AND A.SUPP_ADDRESS = A1.SUPP_ADDRESS
AND A.SUPP_CONTACT_NUMBER = A1.SUPP_CONTACT_NUMBER
AND A.SUPP_EMAIL = A1.SUPP_EMAIL
)


WHEN NOT MATCHED THEN INSERT (
A.SUPP_CONTACT_NAME,
A.SUPP_ADDRESS,
A.SUPP_CONTACT_NUMBER,
A.SUPP_EMAIL
) VALUES (
A1.SUPP_CONTACT_NAME,
A1.SUPP_ADDRESS,
A1.SUPP_CONTACT_NUMBER,
A1.SUPP_EMAIL
);

COMMIT;

MERGE INTO XXBCM_SUPPLIER B
USING (
SELECT DISTINCT y.CONTACT_id, x_SUPPLIER_NAME
FROM XXBCM_ORDER_MGT x
INNER JOIN XXBCM_CONTACT y ON x.SUPP_CONTACT_NAME = y.SUPP_CONTACT_NAME AND x.SUPP_ADDRESS = y.SUPP_ADDRESS AND GET_VALIDATED_PHONENUMBER(x.SUPP_CONTACT_NUMBER) = y.SUPP_CONTACT_NUMBER AND x.SUPP_EMAIL = y.SUPP_EMAIL
) B1 ON (
B.SUPPLIER_NAME = B1.SUPPLIER_NAME
)

WHEN NOT MATCHED THEN INSERT (
B.CONTACT_ID,
B.SUPPLIER_NAME
) VALUES (
B1.CONTACT_ID,
B1.SUPPLIER_NAME
);

COMMIT;

MERGE INTO XXBCM_ORDER C
USING (
SELECT DISTINCT y.SUPPLIER_ID, x.ORDER_REF, GET_VALIDATED_DATE(x.ORDER_DATE) AS ORDER_DATE, GET_VALIDATED_NUMER(x.ORDER_TOTAL_AMOUNT) AS ORDER_TOTAL_AMOUNT, ORDER_DESCRIPTION, ORDER_STATUS, GET_VALIDATED_NUMBER(x.ORDER_LINE_AMOUNT) AS ORDER_LINE_AMOUNT
FROM XXBCM_ORDER_MGT x
INNER JOIN XXBCM_SUPPLIER y ON x_SUPPLIER_NAME = y.SUPPLIER_NAME
) C1 ON (
C.ORDER_REF = C1.ORDER_REF
AND C.ORDER_REF = C1.ORDER_REF
AND C.ORDER_DATE = C1.ORDER_DATE
AND C.ORDER_TOTAL_AMOUNT = C1.ORDER_TOTAL_AMOUNT
AND C.ORDER_DESCRIPTION = C1.ORDER_DESCRIPTION
AND C.ORDER_STATUS = C1.ORDER_STATUS
AND C.ORDER_LINE_AMOUNT = C1.ORDER_LINE_AMOUNT
)

WHEN NOT MATCHED THEN INSERT (
C.SUPPLIER_ID,
C.ORDER_REF,
C.ORDER_DATE,
C.ORDER_TOTAL_AMOUNT,
C.ORDER_DESCRIPTION,
C.ORDER_STATUS,
C.ORDER_LINE_AMOUNT
) VALUES (
C1.SUPPLIER_ID,
C1.ORDER_REF,
C1.ORDER_DATE,
C1.ORDER_TOTAL_AMOUNT,
C1.ORDER_DESCRIPTION,
C1.ORDER_STATUS,
C1.ORDER_LINE_AMOUNT
);

COMMIT;

MERGE INTO XXBCM_INVOICE D
USING (
SELECT DISTINCT y.ORDER_ID, x.INVOICE_REFERENCE, GET_VALIDATED_DATE(x.INVOICE_DATE) AS INVOICE_DATE, x.INVOICE_STATUS, x.INVOICE_HOLD_REASON, GET_VALIDATED_NUMBER(x.INVOICE_AMOUNT) AS x.INVOICE_AMOUNT, INVOICE_DESCRIPTION
FROM XXBCM_ORDER_MGT x
INNER JOIN XXBCM_ORDER y ON x.ORDER_REF = y.ORDER_REF AND GET_VALIDATED_DATE(x.ORDER_DATE) = y.ORDER_DATE AND GET_VALIDATED_NUMBER(x.ORDER_TOTAL_AMOUNT) = y.ORDER_TOTAL_AMOUNT AND x.ORDER_DESCRIPTION = y.ORDER_DESCRIPTION AND x.ORDER_STATUS = y.ORDER_STATUS AND
GET_VALIDATED_NUMBER(x.ORDER_LINE_AMOUNT) AS y.ORDER_LINE_AMOUNT 
)
D1 ON (
D.INVOICE_REFERENCE = D1.INVOICE_REFERENCE
AND D.INVOICE_DATE = D1.INVOICE_DATE
AND D.INVOICE_STATUS = D1.INVOICE_STATUS
AND D.INVOICE_HOLD_REASON = D1.INVOICE_HOLD_REASON
AND D.INVOICE_AMOUNT = D1.INVOICE_AMOUNT
AND D.INVOICE_DESCRIPTION = D1.INVOICE_DESCRIPTION
)
WHEN NOT MATCHED THEN INSERT (
D.ORDER_ID,
D.INVOICE_REFERENCE,
D.INVOICE_DATE,
D.INVOICE_STATUS,
D.INVOICE_HOLD_REASON,
D.INVOICE_AMOUNT,
D.INVOICE_DESCRIPTION
) VALUES (
D1.ORDER_ID,
D1.INVOICE_REFERENCE,
D1.INVOICE_DATE,
D1.INVOICE_STATUS,
D1.INVOICE_HOLD_REASON,
D1.INVOICE_AMOUNT,
D1.INVOICE_DESCRIPTION
);
COMMIT;
    
END;
/


    
    