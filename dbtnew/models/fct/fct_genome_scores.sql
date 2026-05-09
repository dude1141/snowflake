{{ config(materialized = 'table') }}

with src_scores as (select * from {{ ref ('src_genome_scores')}})

select movie_id, tag_id, ROUND(relevance,4) as relevance_score
From src_scores where relevance > 0