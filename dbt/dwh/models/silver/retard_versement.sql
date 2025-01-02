WITH bordereaux_status AS (
    SELECT
        "Code Boutique",
        num_doc,
        COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp AS date_creation,
        situation,
        cod_bq,
        cod_agc,
        cod_cpt,
        note,
        cod_user,
        COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp AS date_journee,
        total, 
        COALESCE(NULLIF(NULLIF(dat_sort, ''), ' '), NULL)::timestamp AS date_sortie,
        dat_maj
    FROM {{ ref('raw_recettes_journalieres') }}
)
SELECT *,
       -- Ajout de la colonne "statut_retard" pour indiquer un retard si date_sortie est plus de 24h après date_journee
       CASE 
           WHEN EXTRACT(EPOCH FROM (date_sortie - date_journee)) / 3600 > 24 THEN 'retard'
           ELSE 'non retard'
       END AS statut_retard
FROM bordereaux_status
ORDER BY "Code Boutique", num_doc
