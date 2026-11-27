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