
DROP SEQUENCE contact_seq;
CREATE SEQUENCE contact_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE TABLE XXBCM_CONTACT
(
	CONTACT_ID 			NUMBER(10) DEFAULT contact_seq.nextval,
	SUPP_CONTACT_NAME 		VARCHAR(50),
	SUPP_ADDRESS 			VARCHAR(100),
	SUPP_CONTACT_NUMBER 		VARCHAR(50),
	SUPP_EMAIL 			VARCHAR(50),
	
	CONSTRAINT pk_contact PRIMARY KEY (CONTACT_ID)
);


CREATE SEQUENCE supplier_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


CREATE TABLE XXBCM_SUPPLIER
(
	SUPPLIER_ID 			NUMBER(10) DEFAULT supplier_seq.nextval,
	CONTACT_ID 			NUMBER(10),
	SUPPLIER_NAME 			VARCHAR(50),
	
	CONSTRAINT pk_supplier PRIMARY KEY (SUPPLIER_ID),
	CONSTRAINT fk_supplier FOREIGN KEY (CONTACT_ID) REFERENCES XXBCM_CONTACT(CONTACT_ID)
);


CREATE SEQUENCE order_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE XXBCM_ORDER
(
	ORDER_ID 			NUMBER(10) DEFAULT order_seq.nextval,
	SUPPLIER_ID 			NUMBER(10),
	ORDER_REF 			VARCHAR(20),
	ORDER_DATE 			DATE,
	ORDER_TOTAL_AMOUNT 		NUMBER(10),
	ORDER_DESCRIPTION 		VARCHAR(100),
	ORDER_STATUS 			VARCHAR(10),
	ORDER_LINE_AMOUNT		NUMBER(10),

	CONSTRAINT pk_order PRIMARY KEY (ORDER_ID),
	CONSTRAINT fk_order FOREIGN KEY (SUPPLIER_ID) REFERENCES XXBCM_SUPPLIER(SUPPLIER_ID)
);

CREATE SEQUENCE invoice_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE XXBCM_INVOICE
(
	INVOICE_ID			NUMBER(10) DEFAULT invoice_seq.nextval,
	ORDER_ID			NUMBER(10),
	INVOICE_REFERENCE		VARCHAR(20),
	INVOICE_DATE			DATE,
	INVOICE_STATUS 			VARCHAR(10),
	INVOICE_HOLD_REASON		VARCHAR(50),
	INVOICE_AMOUNT			NUMBER(10),
	INVOICE_DESCRIPTION 		VARCHAR(50),

	CONSTRAINT pk_invoice PRIMARY KEY (INVOICE_ID),
	CONSTRAINT fk_invoice FOREIGN KEY (ORDER_ID) REFERENCES XXBCM_ORDER(ORDER_ID)

);
