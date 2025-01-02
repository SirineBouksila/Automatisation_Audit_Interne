WITH base_dates AS (
    {{ dbt_date.get_base_dates(start_date="2024-01-01", end_date="2024-12-30", datepart="day") }}
),
calendar AS (
    -- Utilisation de la colonne correcte générée par la macro
    SELECT 
        date_day AS calendar_date  -- date_day est la colonne générée par la macro
    FROM base_dates
    --WHERE EXTRACT(DOW FROM date_day) != 0  -- Exclure les dimanches
)

SELECT 
    c.calendar_date,  -- La date du calendrier
    r.*,  -- Toutes les informations de la table raw_recettes_journalieres
    CASE 
        WHEN r.date_journee IS NOT NULL AND DATE(r.date_journee) = c.calendar_date THEN 'Journée Travaillée'
        ELSE 'Non Travaillée'
    END AS journee_statut  -- Statut de la journée (Travaillée ou Non Travaillée)
FROM calendar c
LEFT JOIN {{ ref('raw_recettes_journalieres') }} r
    ON DATE(r.date_journee) = c.calendar_date  -- Correspondance avec la date de la journée
ORDER BY c.calendar_date
