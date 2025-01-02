WITH base_dates AS (
    {{ dbt_date.get_base_dates(start_date="2024-01-01", end_date="2024-12-30", datepart="day") }}
),
calendar AS (
    SELECT 
        date_day AS calendar_date  -- Générée par la macro dbt_date
    FROM base_dates
),
journees_avec_statut AS (
    SELECT 
        c.calendar_date,
        r.*,  -- Sélectionner toutes les colonnes de raw_recettes_journalieres
        -- Vérifier si la journée a été travaillée
        CASE 
            WHEN r.date_journee IS NOT NULL THEN 'Travaillée'
            ELSE 'Non Travaillée'
        END AS statut_travail,
        -- Vérifier si la journée a été versée ou non
        CASE 
            WHEN r.dat_sort IS NOT NULL AND TRIM(r.dat_sort) != '' THEN 'Versée'
           -- WHEN r.date_journee IS NOT NULL AND (r.dat_sort IS NULL OR TRIM(r.dat_sort) = '') THEN 'Non Versée'
            ELSE 'Non Versée'
        END AS statut_verse
    FROM calendar c
    LEFT JOIN {{ ref('raw_recettes_journalieres') }} r
        ON DATE(r.date_journee) = c.calendar_date
)
SELECT *
FROM journees_avec_statut
ORDER BY calendar_date