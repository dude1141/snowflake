{{

        config(
                materialized ='incremental',
                on_schema_change='fail'
        )


}}

with src_ratings as (select * from {{ref ('src_ratings')}})

select user_id,movie_id, rating, rating_timestamp from src_ratings where rating is not null

{%if is_incremental() %}
    AND rating_timestamp > (select max(rating_timestamp) from {{this}})
{% endif %}

/*
src_ratings(base table) ==5pm(maxtimestamp) --> 6pm(newrowgot added)
fct ratings(fact table)  === had 5pm till now
after 6pmrow got added in srcratings , 


---> AND rating_timestamp is coming from src_ratings
---> max(rating_timestamp)) from {{this}} comes from factratings 
AND rating_timestamp > (select max(rating_timestamp)) from {{this}}
        6            >          5

src table  5--->6
fact tablke 5
     

        rating_timestamp > (select max(rating_timestamp)) from {{this}}
        6 src  > 5 fact tabel which is true now the fact gtable gets updatred
           */