{{
    config(
        materialized='view',
        on_schema_change='fail',
    )
}}

WITH raw_recettes_journalieres AS (
    SELECT 
        *
    FROM {{ source('dwh', 'airbyte_recettes_journalieres') }}
)
SELECT
    "Code Boutique",
    num_doc,
    dat_crea,
    situation,
    cod_bq,
    cod_agc,
    cod_cpt,
    note,
    cod_user,
    date_journee,
    cast(REPLACE(total, ' ', '') as float) as total, 
    dat_sort,
    dat_maj
FROM raw_recettes_journalieres