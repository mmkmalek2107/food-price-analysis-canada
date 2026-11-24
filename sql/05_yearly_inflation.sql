-- Business Question:
-- How has the average annual price of each food product
-- evolved compared to the previous year?

WITH prix_moyen_annuel AS (
    SELECT
        produit,
        annee,
        ROUND(AVG(prix), 2) AS prix_moyen_annuel
    FROM food_prices_clean
    GROUP BY produit, annee
),

evolution AS (
    SELECT
        produit,
        annee,
        prix_moyen_annuel,

        LAG(prix_moyen_annuel)
        OVER (
            PARTITION BY produit
            ORDER BY annee
        ) AS prix_annee_precedente

    FROM prix_moyen_annuel
)

SELECT
    produit,
    annee,
    prix_moyen_annuel,

    COALESCE(
        prix_annee_precedente,
        0
    ) AS prix_annee_precedente,

    ROUND(
        prix_moyen_annuel
        - COALESCE(prix_annee_precedente, 0),
        2
    ) AS difference

FROM evolution;