// Cloning Schema
CREATE SCHEMA OUR_FIRST_DB.COPIED_SCHEMA_CLONE
CLONE OUR_FIRST_DB.PUBLIC;

SELECT * FROM OUR_FIRST_DB.COPIED_SCHEMA_CLONE.ORDERS


// Cloning table
CREATE TABLE OUR_FIRST_DB.COPIED_SCHEMA_CLONE.ORDERS_CLONE
CLONE OUR_FIRST_DB.PUBLIC.ORDERS;

select * from OUR_FIRST_DB.COPIED_SCHEMA_CLONE.ORDERS_CLONE;

select count(1) from OUR_FIRST_DB.PUBLIC.ORDERS;

// Cloning Database
CREATE DATABASE OUR_FIRST_DB_CLONECOPY
CLONE OUR_FIRST_DB;

DROP DATABASE OUR_FIRST_DB_COPY
DROP SCHEMA OUR_FIRST_DB.EXTERNAL_STAGES_COPIED
DROP SCHEMA OUR_FIRST_DB.COPIED_SCHEMA


#cloning creates copy
#Answer: Zero-copy cloning refers to Snowflakes ability to create clones that do not duplicate data.
Instead, the clone references the original data at the time of cloning.
Any subsequent changes to the original or the clone are stored separately, allowing them to diverge over time.

you can create clone and use TimeTravel:

CREATE TABLE my_table_clone CLONE my_table AT (TIMESTAMP = 2023-07-01 12:00:0039;);
Creating a clone of a database as it existed at a specific timestamp:

SELECT * FROM my_table AT (TIMESTAMP => 2023-07-01 12:00:0039);

  
