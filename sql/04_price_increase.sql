-- Business Question:
-- Which food products experienced the highest price increase
-- between January 2020 and September 2026?

WITH select_dates AS (
    SELECT
        produit,
        MIN(date) AS date_min,
        MAX(date) AS date_max
    FROM food_prices_clean
    GROUP BY produit
),

prix_min AS (
    SELECT
        sd.produit,
        sd.date_min,
        fpc.prix AS prix_debut
    FROM food_prices_clean fpc
    JOIN select_dates sd
        ON fpc.produit = sd.produit
       AND fpc.date = sd.date_min
),

prix_max AS (
    SELECT
        sd.produit,
        sd.date_max,
        fpc.prix AS prix_fin
    FROM food_prices_clean fpc
    JOIN select_dates sd
        ON fpc.produit = sd.produit
       AND fpc.date = sd.date_max
)

SELECT
    pm.produit,
    pm.prix_debut,
    px.prix_fin,
	ROUND(((px.prix_fin - pm.prix_debut)/ pm.prix_debut)*100,2) AS inflation_pct

FROM prix_min pm
JOIN prix_max px
    ON pm.produit = px.produit
ORDER BY inflation_pct DESC
LIMIT 10;