with fct_movie_w_tgas as (select * from {{ref('dim_movies_with_tags')}})

select * from fct_movie_w_tgas