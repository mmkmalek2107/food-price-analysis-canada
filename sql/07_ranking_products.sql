-- ==========================================================
-- ANALYSE 1
-- Produits les plus volatils
--
-- Question métier :
-- Quels produits ont connu les plus fortes variations
-- de prix entre leur minimum et leur maximum observés ?
--
-- Objectif :
-- Identifier les produits les plus sensibles aux
-- chocs de prix et à la saisonnalité.
-- ==========================================================

WITH prix_min_max AS (
SELECT
	produit,
	MIN(prix) AS prix_min,
	MAX(prix) AS prix_max
FROM
	food_prices_clean
GROUP BY produit
)

SELECT
	produit,
	prix_min,
	prix_max,
	ROUND((prix_max-prix_min),2) AS ecart_absolu,
	ROUND(((prix_max-prix_min)*100)/prix_min) AS ecart_pourcentage
FROM
	prix_min_max
ORDER BY ecart_pourcentage DESC;


-- ==========================================================
-- ANALYSE 2
-- Date du pic de prix
--
-- Question métier :
-- À quel moment chaque produit a-t-il atteint son
-- prix le plus élevé ?
--
-- Objectif :
-- Identifier les périodes où les pressions
-- inflationnistes ont été les plus fortes.
-- ==========================================================

WITH prix_max AS (
    SELECT
        produit,
        MAX(prix) AS prix_max
    FROM food_prices_clean
    GROUP BY produit
)
SELECT
    fpc.produit,
    pm.prix_max,
    fpc.date AS date_du_pic

FROM food_prices_clean fpc

JOIN prix_max pm
    ON fpc.produit = pm.produit
   AND fpc.prix = pm.prix_max;
   
-- ==========================================================
-- ANALYSE 3
-- Produits encore proches de leur sommet historique
--
-- Question métier :
-- Quels produits demeurent à proximité de leur
-- prix maximal observé ?
--
-- Objectif :
-- Identifier les produits dont les prix restent
-- sous une forte pression inflationniste.
-- Critère :
-- Prix final >= 95 % du prix maximal historique.
-- ==========================================================

WITH prix_max AS (
    SELECT
        produit,
        MAX(prix) AS prix_max
    FROM food_prices_clean
    GROUP BY produit
),

prix_final AS (
    SELECT
        produit,
        prix AS prix_final
    FROM food_prices_clean
    WHERE date = '2026-09-01'
)

SELECT
    pf.produit,
    pm.prix_max,
    pf.prix_final
FROM prix_final pf
JOIN prix_max pm
    ON pf.produit = pm.produit
WHERE prix_final >= prix_max * 0.95;


-- ==========================================================
-- ANALYSE 4
-- Produits revenus près du niveau pré-pandémie
--
-- Question métier :
-- Quels produits affichent aujourd'hui un prix
-- similaire à celui observé en janvier 2020 ?
--
-- Objectif :
-- Identifier les produits dont les prix ont
-- relativement peu changé depuis la pandémie.
-- Critère :
-- Écart maximum de 10 %.
-- ==========================================================

WITH donnees_depart AS (
SELECT
	produit,
	prix as prix_jan_2020
FROM food_prices_clean
WHERE date='2020-01-01'
),

donnees_fin AS (
SELECT
	produit,
	prix as prix_sept_2026
FROM food_prices_clean
WHERE date='2026-09-01'
),

analyses AS (
SELECT
	donnees_depart.produit,
	donnees_depart.prix_jan_2020,
	donnees_fin.prix_sept_2026,
	round((prix_sept_2026 - prix_jan_2020),2) as ecart,
	round((((prix_sept_2026 - prix_jan_2020)/prix_jan_2020)*100),2) as ecart_pourcentage
FROM donnees_depart
JOIN donnees_fin ON donnees_depart.produit=donnees_fin.produit
)

SELECT
	produit,
	prix_jan_2020,
	prix_sept_2026,
	ecart,
	ecart_pourcentage
FROM analyses
WHERE ABS(ecart_pourcentage)<=10;

-- ==========================================================
-- ANALYSE 5
-- Produits moins chers qu'avant la pandémie
--
-- Question métier :
-- Quels produits coûtent aujourd'hui moins cher
-- qu'en janvier 2020 ?
--
-- Objectif :
-- Identifier les produits ayant complètement
-- absorbé les hausses de prix sur la période.
-- ==========================================================

WITH donnees_depart AS (
SELECT
	produit,
	prix as prix_jan_2020
FROM food_prices_clean
WHERE date='2020-01-01'
),

donnees_fin AS (
SELECT
	produit,
	prix as prix_sept_2026
FROM food_prices_clean
WHERE date='2026-09-01'
),

analyses AS (
SELECT
	donnees_depart.produit,
	donnees_depart.prix_jan_2020,
	donnees_fin.prix_sept_2026,
	round((prix_sept_2026 - prix_jan_2020),2) as ecart,
	round((((prix_sept_2026 - prix_jan_2020)/prix_jan_2020)*100),2) as ecart_pourcentage
FROM donnees_depart
JOIN donnees_fin ON donnees_depart.produit=donnees_fin.produit
)

SELECT
	produit,
	prix_jan_2020,
	prix_sept_2026,
	ecart,
	ecart_pourcentage
FROM analyses
WHERE ecart_pourcentage<0;

-- ==========================================================
-- ANALYSE 6
-- Parcours des prix depuis la pandémie
--
-- Question métier :
-- Pour chaque produit, comparer :
-- - le prix de janvier 2020
-- - le prix maximal observé
-- - la date du pic
-- - le prix final en septembre 2026
--
-- Objectif :
-- Déterminer si un produit :
-- - continue sa progression,
-- - est toujours à son sommet,
-- - ou a corrigé après une période d'inflation.
-- ==========================================================

WITH initial_datas AS(
SELECT
	produit,
	prix as prix_jan_2020
FROM
	food_prices_clean
WHERE date='2020-01-01'
),

final_datas AS(
SELECT
	produit,
	prix as prix_final
FROM
	food_prices_clean
WHERE date='2026-09-01'
),

maximum AS(
SELECT
	produit,
	MAX(prix) as prix_max
FROM
	food_prices_clean
GROUP BY produit
),

pic AS (
SELECT
	food_prices_clean.produit,
	maximum.prix_max,
	food_prices_clean.date as date_pic
FROM food_prices_clean
JOIN maximum ON food_prices_clean.produit = maximum.produit  AND food_prices_clean.prix = maximum.prix_max
)

SELECT
	initial_datas.produit,
	initial_datas.prix_jan_2020,
	pic.prix_max,
	pic.date_pic,
	final_datas.prix_final
	
FROM	initial_datas
JOIN	final_datas ON final_datas.produit=initial_datas.produit
JOIN	pic ON		initial_datas.produit=pic.produit;
