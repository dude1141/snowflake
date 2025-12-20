use DATABASE MYDB;

CREATE OR REPLACE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name STRING,
    order_date DATE,
    total_amount NUMBER(10,2),
    status STRING
);

CREATE OR REPLACE TABLE orders_stg (
    order_id INT,
    customer_name STRING,
    order_date DATE,
    total_amount NUMBER(10,2),
    status STRING
);

INSERT INTO orders VALUES (1, 'Alice', '2024-01-01', 500.00, 'Completed');
INSERT INTO orders VALUES (2, 'Bob', '2024-01-02', 700.00, 'Pending');

INSERT INTO orders_stg VALUES (2, 'Bob', '2024-01-02', 750.00, 'Completed');
INSERT INTO orders_stg VALUES (3, 'Charlie', '2024-01-05', 900.00, 'Pending');
INSERT INTO orders_stg VALUES (4, 'Harlie', '2024-01-05', 1000.00, 'Pending');


select * From orders_stg;
select * From orders;


-- delete from  orders_stg;


CREATE OR REPLACE TABLE error_log (
    error_id INT AUTOINCREMENT PRIMARY KEY,
    procedure_name STRING,
    error_message STRING,
    error_time TIMESTAMP
);

select * from orders;


-- Include error handling:
CREATE OR REPLACE PROCEDURE SP_INCREMENTAL_LOAD()
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
BEGIN
    -- Update existing records
    UPDATE orders
    SET
        customer_name = s.customer_name,
        order_date = s.order_date,
        total_amount = s.total_amount,
        status = s.status
    FROM orders_stg s
    WHERE orders.order_id = s.order_id;

    -- Insert new records
    INSERT INTO orders
    SELECT s.* FROM orders_stg s
    WHERE NOT EXISTS (
        SELECT 1 FROM orders o WHERE o.order_id = s.order_id
    );

    RETURN 'Incremental Load Completed Successfully!';
END;
END;

CALL SP_INCREMENTAL_LOAD();


/*
SELECT s.* FROM orders_stg s
    WHERE NOT EXISTS (
        SELECT 1 FROM orders o WHERE o.order_id = s.order_id
    ); */

select * FROM orders;


-- Implementing the error handling
CREATE OR REPLACE PROCEDURE SP_INCREMENTAL_LOAD()
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
DECLARE error_message STRING;

BEGIN
    -- Update existing orders
    UPDATE orders
    SET
        customer_name = s.customer_name,
        order_date = s.order_date,
        total_amount = s.total_amount,
        status = s.status
    FROM orders_stg s
    WHERE orders.order_id = s.order_id;

    -- Insert new records
    INSERT INTO orders
    SELECT s.* FROM orders_stg s
    WHERE NOT EXISTS (
        SELECT 1 FROM orders o WHERE o.order_id = s.order_id
    );

    RETURN 'Incremental Load Completed Successfully!';

         EXCEPTION
        -- Catch any exception that occurs during the INSERT operation
        WHEN OTHER  THEN
            -- If an error occurs, set v_status to 'FAILED' and capture the error message
            LET  v_status := 'FAILED' ;

           INSERT INTO error_log (procedure_name, error_message, error_time)
            VALUES ('SP_INCREMENTAL_LOAD', :v_status, CURRENT_TIMESTAMP);

   
END;
END;


CALL SP_INCREMENTAL_LOAD();





CREATE OR REPLACE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name STRING,
    order_date DATE,
    total_amount NUMBER(10,2),
    status STRING
);

CREATE OR REPLACE TABLE error_log (
    error_id INT AUTOINCREMENT PRIMARY KEY,
    procedure_name STRING,
    error_message STRING,
    error_time TIMESTAMP
);


INSERT INTO orders (order_id, customer_id, customer_name, order_date, total_amount, status) VALUES
(101, 1, 'John Doe', '2024-01-10', 500, 'Shipped'),
(102, 2, 'Alice Smith', '2024-01-15', 800, 'Pending'),
(103, 1, 'John Doe', '2024-02-05', 1200, 'Delivered');

select * From orders;


//-- Using resultset VARIABLE
CREATE OR REPLACE PROCEDURE GET_CUSTOMER_ORDERS(C_ID INT)
RETURNS TABLE ()
LANGUAGE SQL
AS
BEGIN
    -- Execute dynamic SQL and assign result to RS
    declare
    res resultset default (
                SELECT order_id, customer_id,order_date, total_amount, status
                FROM orders WHERE customer_id = :C_ID
    ) ;      
    begin
        return table(res);
    end;
   
    EXCEPTION
    WHEN OTHER  THEN
    LET  v_status := 'FAILED' ;
   
    INSERT INTO error_log (procedure_name, error_message, error_time)
    VALUES ('SP_INCREMENTAL_LOAD', :v_status, CURRENT_TIMESTAMP);            

END;

call GET_CUSTOMER_ORDERS(1);


// dml with transactions

CREATE OR REPLACE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name STRING,
    balance NUMBER(10,2)
);

CREATE OR REPLACE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount NUMBER(10,2),
    status STRING
);

CREATE OR REPLACE TABLE error_log (
    procedure_name STRING,
    error_message STRING,
    error_time TIMESTAMP
);




-----

INSERT INTO customers (customer_id, customer_name, balance)
VALUES (101, 'John Doe', 100.00);  -- Only $100 balance

INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
VALUES (5000, 101, '2025-02-11', 50.00, 'CONFIRMED'); -- Existing order

select * from orders;


------ Implementing the transactions
CREATE OR REPLACE PROCEDURE PROCESS_ORDER(
    P_ORDER_ID INT,
    P_CUSTOMER_ID INT,
    P_ORDER_AMOUNT NUMBER(10,2),
    P_order_date  DATE
)
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
DECLARE V_STATUS STRING;

BEGIN
    -- Start a transaction
    BEGIN TRANSACTION;

    -- Insert new order
    INSERT INTO orders (order_id, customer_id, order_date, total_amount, status)
    VALUES (:P_ORDER_ID, :P_CUSTOMER_ID, :P_order_date, :P_ORDER_AMOUNT, 'CONFIRMED');

    -- Update customer balance
    UPDATE customers
    SET balance = balance - :P_ORDER_AMOUNT
    WHERE customer_id = :P_CUSTOMER_ID;

    -- Delete canceled orders (for cleanup)
    DELETE FROM orders WHERE status = 'CANCELED';

    -- Commit if everything is successful
    COMMIT;
   
    RETURN 'Transaction Successful';

EXCEPTION
    WHEN OTHER THEN
        -- Rollback on error
        ROLLBACK;

        -- Capture error details
        LET  v_status := SQLERRM ;


        -- Log the error
        INSERT INTO error_log (procedure_name, error_message, error_time)
        VALUES ('PROCESS_ORDER', :v_status, CURRENT_TIMESTAMP);

        -- Return failure message
        RETURN 'Transaction Failed! Check error_log table.';

END;
END;


CALL PROCESS_ORDER(2, '5001', 200.00);

CALL PROCESS_ORDER(101, 5001, 200,'2025-02-22');

select * from ORDERS_STAGING






CREATE OR REPLACE STAGE aws_stage
url='s3://bucketsnowflakes3'
file_format= (type = csv field_delimiter=',' skip_header=1)

CREATE OR REPLACE TRANSIENT TABLE ORDERS_STAGING (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30),
    customer_id INT,
    email STRING,
    phone STRING,
    FileName STRING
    );

 
   
CREATE OR REPLACE TABLE ORDERS_GOODDATA (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30),
    customer_id INT,
    email STRING,
    phone STRING,
     FileName STRING,
     LoadStartTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
     LoadEndTime TIMESTAMP
    );

   
 
CREATE OR REPLACE TABLE ORDERS_INVALIDDATA (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30),
    customer_id INT,
    email STRING,
    phone STRING,
    FileName STRING,
    LoadStartTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    LoadEndTime TIMESTAMP ,
     error_reason STRING
    );


    CREATE OR REPLACE TABLE LOG_AUDIT
    (
        FileName STRING,
        DataCategory STRING,
        LoadStartTime TIMESTAMP,
        LoadEndTime TIMESTAMP,
        RecorCounts INT
    );

    select * from LOG_AUDIT
 
   

select * from ORDERS_STAGING



CREATE OR REPLACE NOTIFICATION INTEGRATION my_email_int
  TYPE=EMAIL
  ENABLED=TRUE
  DEFAULT_RECIPIENTS = ('ss@gmail.com')
  DEFAULT_SUBJECT = 'Service status';





CREATE OR REPLACE PROCEDURE Data_Quality_Check()
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
    DECLARE goodtablecount INT;
            badtablecount INT;
            LoadStartTime TIMESTAMP;  

BEGIN
   TRUNCATE TABLE ORDERS_STAGING;
   COPY INTO ORDERS_STAGING(ORDER_ID,AMOUNT,PROFIT,QUANTITY,CATEGORY,SUBCATEGORY,FileName)
    FROM (select
            s.$1,
            s.$2,
            s.$3,
            s.$4,
            s.$5,
            s.$6,
            metadata$filename
          from @aws_stage s
    )
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';


    UPDATE ORDERS_STAGING SET email = 'test@email.com'
    where Amount < 10;

    UPDATE ORDERS_STAGING SET email = 'invalid@email'
    where Amount between 10 and 12 ;

    UPDATE ORDERS_STAGING SET email = 'user@domain..com'
    where Amount between 13 and 45 ;

    UPDATE ORDERS_STAGING SET email = 'user@.com'
    where Amount between 101 and 800 ;

    UPDATE ORDERS_STAGING SET email = 'user com'
    where Amount > 800;


    UPDATE ORDERS_STAGING SET phone = '0000000000'
    where Amount < 10;

    UPDATE ORDERS_STAGING SET phone = '00000000000'
    where Amount between 10 and 12 ;

    UPDATE ORDERS_STAGING SET phone = '11111111'
    where Amount between 13 and 45 ;

    UPDATE ORDERS_STAGING SET phone = '22222222222222'
    where Amount between 101 and 800 ;

    UPDATE ORDERS_STAGING SET phone = '2345'
    where Amount > 800;

    SELECT COUNT(distinct FileName)
    into goodtablecount
    FROM ORDERS_STAGING
    WHERE substring(FileName, 1, length(FileName)-4) IN (
            select distinct  
            substring(FileName, 1, length(FileName)-4) as ActualFileName
            from ORDERS_GOODDATA    
    );    
   
    SELECT COUNT(distinct FileName)
    into badtablecount
    FROM ORDERS_STAGING
    WHERE substring(FileName, 1, length(FileName)-4) IN (
            select distinct  
            substring(FileName, 1, length(FileName)-4) as ActualFileName
            from ORDERS_INVALIDDATA    
    );

    IF (:goodtablecount = 0 and :badtablecount = 0) THEN  --if file has never been processed

       
    --TRUNCATE TABLE ORDERS_GOODDATA;
    --TRUNCATE TABLE ORDERS_INVALIDDATA;
   
    INSERT INTO ORDERS_GOODDATA(
            ORDER_ID,
            AMOUNT,
            PROFIT,
            QUANTITY,
            CATEGORY,
            SUBCATEGORY,
            customer_id,
            email,phone,
            FileName
        )
    SELECT  ORDER_ID,
            AMOUNT,
            PROFIT,
            QUANTITY,
            CATEGORY,
            SUBCATEGORY,
            customer_id,
            email,phone,
            FileName
    FROM ORDERS_STAGING
    WHERE
        email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' -- valid email check
        AND phone REGEXP '^[0-9]{10}$'      -- valid phone number check
        AND profit >= 0;
        /*
        --file existance check
        AND substring(FileName, 1, length(FileName)-4) NOT IN (
            select distinct  
            substring(FileName, 1, length(FileName)-4) as ActualFileName
            from ORDERS_GOODDATA
       
        )
        */

    UPDATE ORDERS_GOODDATA
    SET LoadEndTime = CURRENT_TIMESTAMP
    WHERE substring(FileName, 1, length(FileName)-4) IN (
        select distinct  
        substring(FileName, 1, length(FileName)-4) as ActualFileName
        from ORDERS_STAGING        
    );

    INSERT INTO LOG_AUDIT
    SELECT
        substring(FileName, 1, length(FileName)-4) AS FileName,
        'ValidData' AS DataCategory,
        MIN(LoadStartTime) AS LoadStartTime,
        MAX(LoadEndTime) AS LoadStartTime,
        COUNT(1) AS RecordCounts
    FROM ORDERS_GOODDATA
    WHERE substring(FileName, 1, length(FileName)-4) IN (
                select distinct  
                substring(FileName, 1, length(FileName)-4) as ActualFileName
                from ORDERS_STAGING        
            )
    GROUP BY substring(FileName, 1, length(FileName)-4);
       
     
    -- Insert invalid records into bad table
    INSERT INTO ORDERS_INVALIDDATA
        (
            ORDER_ID,
            AMOUNT,
            PROFIT,
            QUANTITY,
            CATEGORY,
            SUBCATEGORY,
            customer_id,
            email,phone,
            FileName,
            error_reason
        )
    SELECT ORDER_ID,
            AMOUNT,
            PROFIT,
            QUANTITY,
            CATEGORY,
            SUBCATEGORY,
            customer_id,
            email,phone,
            FileName,            
            CASE
                WHEN email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 'Invalid Email'
                WHEN phone NOT REGEXP '^[0-9]{10}$' THEN 'Invalid Phone'  
                WHEN profit < 0 THEN 'Negative Profit'
                ELSE 'Unknown Error'
            END AS error_reason
    FROM ORDERS_STAGING
    WHERE
        (
            (email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR  email IS NULL)                                       OR ( phone NOT REGEXP '^[0-9]{10}$' OR phone IS NULL )
            OR profit < 0 -- invalid profit values check
        );
        /*
        -- file existance check
        AND substring(FileName, 1, length(FileName)-4) NOT IN (
            select distinct  
            substring(FileName, 1, length(FileName)-4) as ActualFileName
            from ORDERS_INVALIDDATA
       
        )
        */
       

       
    UPDATE ORDERS_INVALIDDATA
    SET LoadEndTime = CURRENT_TIMESTAMP
    WHERE substring(FileName, 1, length(FileName)-4) IN (
        select distinct  
        substring(FileName, 1, length(FileName)-4) as ActualFileName
        from ORDERS_STAGING        
    );

    INSERT INTO LOG_AUDIT
    SELECT
        substring(FileName, 1, length(FileName)-4) AS FileName,
        'InvalidData' AS DataCategory,
        MIN(LoadStartTime) AS LoadStartTime,
        MAX(LoadEndTime) AS LoadStartTime,
        COUNT(1) AS RecordCounts
    FROM ORDERS_INVALIDDATA
    WHERE substring(FileName, 1, length(FileName)-4) IN (
                select distinct  
                substring(FileName, 1, length(FileName)-4) as ActualFileName
                from ORDERS_STAGING        
            )
    GROUP BY substring(FileName, 1, length(FileName)-4);

    CALL SYSTEM$SEND_EMAIL(
        'my_email_int',
        'sss@gmail.com',
        'Email Alert: Data Load Status:',
        'Successfully Data has loaded'
      );

       
    RETURN 'Data Processing Completed';

    ELSE  
     

  CALL SYSTEM$SEND_EMAIL(
    'my_email_int',
    'ss@gmail.com',
     'Email Alert: Data Load Status:',
    'Already File(s) has been Processed, Please cross verify once'
  );

  RETURN 'File Already processed, Please check';
         
  END IF;

   
END;
END;



-- 0000000000
-- test@email.com
-- test@email.com

call Data_Quality_Check();

select count(1) from ORDERS_STAGING;
select count(1) from ORDERS_GOODDATA;  --17
select count(1) from ORDERS_INVALIDDATA;    -- 1493
select count(1) from  LOG_AUDIT;

select * from  LOG_AUDIT;


select * from ORDERS_GOODDATA
select * from ORDERS_INVALIDDATA
select * from LOG_AUDIT

TRUNCATE TABLE ORDERS_STAGING;
TRUNCATE TABLE ORDERS_GOODDATA;
TRUNCATE TABLE ORDERS_INVALIDDATA;
TRUNCATE TABLE LOG_AUDIT;

CREATE OR REPLACE TASK Data_Quality_Check
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
AS
call Data_Quality_Check();


ALTER TASK Data_Quality_Check RESUME;
ALTER TASK Data_Quality_Check SUSPEND;



SELECT DISTINCT FileName FROM ORDERS_GOODDATA;
SELECT DISTINCT FileName FROM ORDERS_INVALIDDATA;



SELECT COUNT(distinct FileName)
    --into goodtablecount
    FROM ORDERS_STAGING
    WHERE substring(FileName, 1, length(FileName)-4) IN (
            select distinct  
            substring(FileName, 1, length(FileName)-4) as ActualFileName
            from ORDERS_GOODDATA    
    );    
   
    SELECT COUNT(distinct FileName)
   -- into badtablecount
    FROM ORDERS_STAGING
    WHERE substring(FileName, 1, length(FileName)-4) IN (
            select distinct  
            substring(FileName, 1, length(FileName)-4) as ActualFileName
            from ORDERS_INVALIDDATA    
    );
