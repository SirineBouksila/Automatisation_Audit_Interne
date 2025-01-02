WITH raw_recettes_journalieres AS (
    SELECT 
        *
    FROM {{ ref('raw_recettes_journalieres') }}
),
bordereaux_status AS (
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
        dat_maj,
        -- Statut de génération
        CASE
            WHEN COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp <= COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp THEN 'In Time'
            ELSE 'Late'
        END AS statut_generation,
        
        -- Calcul du retard en secondes, NULL si pas de retard
        CASE
            WHEN COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp > COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp THEN
                EXTRACT(epoch FROM (COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp - COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp))
            ELSE NULL
        END AS retard_duration,
        
        -- Format détaillé de retard (jours, heures, minutes, secondes), NULL si pas de retard
        CASE
            WHEN COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp > COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp THEN
                CONCAT(
                    EXTRACT(day FROM (COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp - COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp)) || ' days ',
                    EXTRACT(hour FROM (COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp - COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp)) || ' hours ',
                    EXTRACT(minute FROM (COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp - COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp)) || ' minutes ',
                    EXTRACT(second FROM (COALESCE(NULLIF(NULLIF(dat_crea, ''), ' '), NULL)::timestamp - COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::timestamp)) || ' seconds'
                )
            ELSE NULL
        END AS retard
    FROM raw_recettes_journalieres
)
SELECT *
FROM bordereaux_status
ORDER BY "Code Boutique", num_doc
