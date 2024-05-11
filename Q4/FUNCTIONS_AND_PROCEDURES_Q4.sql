CREATE OR REPLACE PROCEDURE ORDERS_SUMMARY
    AS
    cursor1 SYS_REFCURSOR;
    BEGIN
        open cursor1 for
    SELECT "Order Reference", "Order Period", "Supplier Name", "Order Total Amount", "Order Status", "Invoice Reference", "Invoice Total Amount", "Action" FROM (

    SELECT DISTINCT LTRIM(REPLACE(B.ORDER_REF, 'PO',''), '0') AS "Order Reference",

    TO_CHAR(B.ORDER_DATE, 'MON-YY') AS "Order Period",

    INITCAP(C.SUPPLIER_NAME) AS "Supplier Name",

    TO_CHAR(B.ORDER_TOTAL_AMOUNT, '99,999,990.00') AS "Order Total Amount",
    
    B.ORDER_STATUS AS "Order Status",
    A.INVOICE_REFERENCE AS "Invoice Reference",

    TO_CHAR(A.INVOICE_AMOUNT, '99,999,990.00') AS "Invoice Total Amount",   
    
    ACTION(A.INVOICE_STATUS) AS "Action",
    ORDER_DATE
    FROM XXBCM_INVOICE A

    INNER JOIN XXBCM_ORDER B ON B.ORDER_ID = A.ORDER_ID
    INNER JOIN XXBCM_SUPPLIER C ON C.SUPPLIER_ID = B.SUPPLIER_ID
    );
    DBMS_SQL.RETURN_RESULT(cursor1);
    END;
    /


CREATE OR REPLACE FUNCTION Action(v_INVOICE_STATUS in VARCHAR2)
    RETURN VARCHAR2 IS
        v_OUTPUT VARCHAR2(15);
            BEGIN
                v_OUTPUT := NVL( v_INVOICE_STATUS, 'To verify');
                
                v_OUTPUT := REPLACE( v_OUTPUT, 'Paid', 'OK');
                
                v_OUTPUT := REPLACE( v_OUTPUT, 'Pending', 'To follow up');
                               
                RETURN v_OUTPUT;
            END;
            /
            