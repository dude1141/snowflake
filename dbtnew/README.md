# MovieLens dbt + Snowflake Pipeline ,part1

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
│   ├── dim/            # Dimension models (tables)
│   └── fct/            # Fact models (tables)
├── dbt_project.yml
└── infographic.html    # Visual pipeline (open in browser)
```

## Key Concepts Used

| Concept | Usage |
|---|---|
| `{{ ref() }}` | Reference other dbt models |
| `{{ source() }}` | Reference raw Snowflake tables |
| `{{ config(materialized='table') }}` | Control table vs view |
| `profiles.yml` | Controls output schema (RAW → DEV) |
| Jinja templating | Dynamic SQL via `{{ }}` |
| CTE pattern | `with x as (...)` in every model |

## Snowflake Setup

- **Database:** `MOVIELENS`
- **Source Schema:** `RAW` (raw loaded tables)
- **Output Schema:** `DEV` (dbt output, set in `profiles.yml`)
- **Warehouse:** `COMPUTE_WH`
- **Role:** `TRANSFORM`

## Run the Project

```bash
pip install dbt-snowflake

dbt run

dbt run --select src_movies

dbt test
```
