CREATE TABLE food_prices_clean AS
SELECT
    produit,
    mois,
    annee,
    CAST(REPLACE(prix, ',', '.') AS REAL) AS prix,
    trimestre,
    date
FROM food_prices;
