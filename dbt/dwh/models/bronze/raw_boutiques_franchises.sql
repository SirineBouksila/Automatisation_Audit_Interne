{{
    config(
        materialized='view',
        on_schema_change='fail',
    )
}}

WITH raw_boutiques_franchises AS (
    SELECT 
        *
    FROM {{ source('dwh', 'airbyte_boutiques_franchises') }}
)
SELECT
    "Code Boutique",
    statut,
    "Code Ville"
FROM raw_boutiques_franchises