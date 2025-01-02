WITH processed_data AS (
    SELECT
        *,
        -- Calcul du retard en secondes (si positif), NULL sinon
        CASE
            WHEN NULLIF(dat_sort, '') IS NOT NULL AND NULLIF(date_journee, '') IS NOT NULL
            THEN EXTRACT(epoch FROM (dat_sort::timestamp - date_journee::timestamp))
            ELSE NULL
        END AS retard_duration
    FROM {{ ref('raw_recettes_journalieres') }}
),

-- Trouve le premier dépassement par boutique (si le retard dépasse 8 jours)
first_exceeding_boutiques AS (
    SELECT
        "Code Boutique",
        MIN(num_doc) AS first_exceeding_doc,
        MIN(dat_sort) AS first_exceeding_dat_sort -- Date sortie du premier dépassement
    FROM processed_data
    WHERE retard_duration > 8 * 24 * 3600  -- 8 jours en secondes
    GROUP BY "Code Boutique"
),

anomaly_detection AS (
    SELECT
        pd.*,  
        CASE
            -- Marque le premier dépassement pour chaque boutique
            WHEN pd.retard_duration > 8 * 24 * 3600 AND pd.num_doc = fe.first_exceeding_doc THEN 'Premier dépassement'
            
            -- Marque comme "Caisse à bloquer" si date_sortie premier dépassement > date_journee et date_sortie actuelles
            WHEN fe.first_exceeding_dat_sort < pd.date_journee OR fe.first_exceeding_dat_sort < pd.dat_sort THEN 'Caisse à bloquer'
            
            -- Marque comme "Pas anomalie" tous les autres cas
            ELSE 'Pas anomalie'
        END AS statut
    FROM processed_data pd
    LEFT JOIN first_exceeding_boutiques fe
        ON pd."Code Boutique" = fe."Code Boutique"
)

SELECT
    "Code Boutique",
    num_doc,
    date_journee,
    dat_sort,
    total,
    statut
FROM anomaly_detection 
ORDER BY "Code Boutique", num_doc
