WITH borderaux_journaliers AS (
    SELECT
        "Code Boutique",
        COALESCE(NULLIF(NULLIF(date_journee, ''), ' '), NULL)::date AS date_journee,
        SUM(CASE 
            WHEN note = 'BORDEREAU DE VERSEMENT ESPECE' THEN total 
            ELSE 0 
        END) AS total_especes,
        SUM(CASE 
            WHEN note = 'BORDEREAU DE VERSEMENT CREDIT' THEN total 
            ELSE 0 
        END) AS total_credits
    FROM {{ ref('raw_recettes_journalieres') }}
    WHERE note NOT IN (
        'BORDEREAU DE VERSEMENT TRAITE A L ENCAISSEMENT'  
    )
    GROUP BY "Code Boutique", date_journee
),
verifications AS (
    SELECT
        "Code Boutique",
        date_journee,
        total_especes,
        total_credits,
        CASE
            WHEN total_especes > 15000 THEN 'Dépassement limite ESPECE'
            WHEN total_credits > 30000 THEN 'Dépassement limite CREDIT'
            ELSE 'Limites respectées'
        END AS statut_verification
    FROM borderaux_journaliers
)
SELECT
    "Code Boutique",
    date_journee,
    total_especes,
    total_credits,
    statut_verification
FROM verifications
ORDER BY "Code Boutique", date_journee
