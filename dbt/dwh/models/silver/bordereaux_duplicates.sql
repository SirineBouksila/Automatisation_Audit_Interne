WITH raw_recettes_journalieres AS (
    SELECT 
        *
    FROM {{ ref('raw_recettes_journalieres') }}
)
SELECT
    r."Code Boutique",
    r.num_doc,
    COALESCE(NULLIF(NULLIF(r.dat_crea, ''), ' '), NULL)::date AS date_creation,
    r.situation,
    r.cod_bq,
    r.cod_agc,
    r.cod_cpt,
    r.note,
    r.cod_user,
    COALESCE(NULLIF(NULLIF(r.date_journee, ''), ' '), NULL)::date AS date_journee,
    r.total, 
    COALESCE(NULLIF(NULLIF(r.dat_sort, ''), ' '), NULL)::date AS date_sortie,
    r.dat_maj,
    COUNT(*) OVER (
        PARTITION BY r."Code Boutique", r.num_doc
    ) AS bordereau_occurence,
    CASE
        WHEN COUNT(*) OVER (PARTITION BY r."Code Boutique", r.num_doc) > 1 THEN 'Doublon'
        ELSE 'Unique'
    END AS statut_bordereau
FROM raw_recettes_journalieres r
ORDER BY r."Code Boutique", r.num_doc