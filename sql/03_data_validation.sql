-- Nettoyage post-import
-- SQLite a importé la ligne d'entête comme une donnée

DELETE FROM food_prices
WHERE date = 'Date';

-- Validation du chargement des données

SELECT COUNT(*) AS total_rows
FROM food_prices;

SELECT COUNT(DISTINCT produit) AS total_products
FROM food_prices;

SELECT
    MIN(date) AS start_date,
    MAX(date) AS end_date
FROM food_prices;

SELECT
    annee,
    COUNT(*) AS total_rows
FROM food_prices
GROUP BY annee
ORDER BY annee;