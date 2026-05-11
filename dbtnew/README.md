# MovieLens dbt + Snowflake Pipeline

End-to-end data pipeline built with **dbt**, **Snowflake**, and **AWS** on the MovieLens dataset.

---

## Pipeline Architecture

![Pipeline Infographic](Screenshot%202026-05-09%20225125.png)

---

## Project Structure

```
dbtnew/
├── models/
│   ├── staging/        # Raw → cleaned (views & tables)
│   ├── dim/            # Dimension models (tables + ephemeral)
│   └── fct/            # Fact models (table, incremental, ephemeral)
├── dbt_project.yml
└── infographic.html    # Visual pipeline (open in browser)
```

## Materialization Types Used

| Type | Models |
|---|---|
| `view` | src_movies, src_ratings, src_raw_links, src_genome_scores, src_genome_tags |
| `table` | src_tags, dim_movies, dim_users, dim_genome_tags, fct_genome_scores |
| `incremental` | fct_ratings |
| `ephemeral` | dim_movies_with_tags, ep_movie_with_tags |

## Snowflake Setup

- **Database:** `MOVIELENS`
- **Source Schema:** `RAW`
- **Output Schema:** `DEV` (set in `profiles.yml`)
- **Warehouse:** `COMPUTE_WH`
- **Role:** `TRANSFORM`

## Run the Project

```bash
pip install dbt-snowflake
dbt run
dbt run --select src_movies
dbt test
```
