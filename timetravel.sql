reloading old run data using offset


drop TABLE OUR_FIRST_DB.public.test;
drop FILE FORMAT MANAGE_DB.file_formats.csv_file;
drop STAGE MANAGE_DB.external_stages.time_travel_stage;



CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test (
    id int,
    first_name string,
    last_name string,
    email string,
    gender string,
    Job string,
    Phone string
);
 
 
CREATE OR REPLACE FILE FORMAT MANAGE_DB.file_formats.csv_file
type = csv
field_delimiter = ','
skip_header = 1;
   

CREATE OR REPLACE STAGE MANAGE_DB.external_stages.time_travel_stage
URL = 's3://data-snowflake-fundamentals/time-travel/'
file_format = MANAGE_DB.file_formats.csv_file;  

list @MANAGE_DB.external_stages.time_travel_stage;    
   
   
COPY INTO OUR_FIRST_DB.public.test
from @MANAGE_DB.external_stages.time_travel_stage
files = ('customers.csv');


SELECT * FROM OUR_FIRST_DB.public.test;  


--UPDATE OUR_FIRST_DB.public.test
SET FIRST_NAME = 'Joyen' ;


SELECT * FROM OUR_FIRST_DB.public.test at (OFFSET => -60*12);

#click on QueryID SELECT * FROM OUR_FIRST_DB.public.test and then click on query history where you used update statement and copy the queryid   
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01b9fba9-030c-1191-000a-d6ef0005600e');


CREATE OR REPLACE TABLE OUR_FIRST_DB.public.test_backup as
SELECT * FROM OUR_FIRST_DB.public.test before (statement => '01b9fba9-030c-1191-000a-d6ef0005600e');

select * from OUR_FIRST_DB.public.test_backup;

TRUNCATE OUR_FIRST_DB.public.test_backup;



show tables like '%test%';





