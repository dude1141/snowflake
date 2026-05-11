{{

    config(materialized = 'ephemeral')


}}


with movies as (select * From {{ref("dim_movies")}}),

tags as (select * From {{ref("dim_genome_tags")}}),

scores as (select * From {{ref("fct_genome_scores")}})

select movieid,movie_title, genres, t.tag_id as tagid ,tag_name from movies m left join scores s on m.movieid=s.movie_id
left join tags t on t.tag_id= s.tag_id