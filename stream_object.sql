stream tracks internally tracks the changes (inserts,updates  deletes )made in to that table. accomplished by micropartitions

stream object--all  changes are captured in stream object. Its used for CDC logic and implement autoincrmental load

metadata action and metadata updates,based on this it loads in to target table.

stream object in to target table,once consumed there will be no data in stream object.






CREATE OR REPLACE DATABASE STREAMS_DB1;

CREATE OR REPLACE TABLE sales_raw_staging (
    id VARCHAR,
    product VARCHAR,
    price VARCHAR,
    amount VARCHAR,
    store_id VARCHAR
);

INSERT INTO sales_raw_staging VALUES
(1, 'Banana', 1.99, 1, 1),
(2, 'Lemon', 0.99, 1, 1),
(3, 'Apple', 1.79, 1, 2),
(4, 'Orange Juice', 1.89, 1, 2),
(5, 'Cereals', 5.98, 2, 1);


CREATE OR REPLACE TABLE store_table (
    store_id NUMBER,
    location VARCHAR,
    employees NUMBER
);

INSERT INTO store_table VALUES (1, 'Chicago', 33);
INSERT INTO store_table VALUES (2, 'London', 12);


CREATE OR REPLACE TABLE sales_final_table (
    id INT,
    product VARCHAR,
    price NUMBER,
    amount INT,
    store_id INT,
    location VARCHAR,
    employees INT
);



--target table
INSERT INTO sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.STORE_ID,
    ST.LOCATION,
    ST.EMPLOYEES
FROM SALES_RAW_STAGING SA
JOIN STORE_TABLE ST ON ST.STORE_ID = SA.STORE_ID;



-- Create a stream object on source table--->sales_raw_staging
CREATE OR REPLACE STREAM sales_stream ON TABLE sales_raw_staging;

SHOW STREAMS;

DESC STREAM sales_stream;

select * from sales_stream;

-- Insert values into sales_raw_staging--soure table
INSERT INTO sales_raw_staging
VALUES
    (6, 'Mango', 1.99, 1, 2),
    (7, 'Garlic', 0.99, 1, 1)   ;

-- Get changes on data using stream (INSERTS)
SELECT * FROM sales_stream;--------(once you load new data in to source table, stream object holds metadata if update or insert and false or true).


select * from sales_final_table;

----load from sales_Stream joning store table in to final sales_final_table.

INSERT INTO sales_final_table
SELECT
    SA.id,
    SA.product,
    SA.price,
    SA.amount,
    ST.STORE_ID,
    ST.LOCATION,
    ST.EMPLOYEES
FROM sales_stream SA
JOIN STORE_TABLE ST ON ST.STORE_ID = SA.STORE_ID;



SELECT * FROM sales_stream;---oonce you load data in to target table from stream object it empties stream object.

