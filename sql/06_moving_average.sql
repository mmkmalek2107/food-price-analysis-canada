-- Business Question:
-- What are the short-term (3 months) and long-term (12 months)
-- price trends for each food product?

WITH moving_average AS (
    SELECT
        produit,
        date,
        prix,

        ROUND(
            AVG(prix) OVER (
                PARTITION BY produit
                ORDER BY date
                ROWS BETWEEN 2 PRECEDING
                     AND CURRENT ROW
            ),
            2
        ) AS moyenne_mobile_3_mois,

        ROUND(
            AVG(prix) OVER (
                PARTITION BY produit
                ORDER BY date
                ROWS BETWEEN 11 PRECEDING
                     AND CURRENT ROW
            ),
            2
        ) AS moyenne_mobile_12_mois

    FROM food_prices_clean
)

SELECT
    produit,
    date,
    prix,
    moyenne_mobile_3_mois,
    moyenne_mobile_12_mois

FROM moving_average
ORDER BY produit, date;