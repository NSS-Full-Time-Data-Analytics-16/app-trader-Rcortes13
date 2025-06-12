------------------------------------------------------------------------------------------------
--Exploratory Data Analysis
------------------------------------------------------------------------------------------------
SELECT *
FROM play_store_apps
LIMIT 10;

SELECT *
FROM app_store_apps
LIMIT 10;

--dups in playstore
SELECT name, count(*)
FROM play_store_apps
GROUP BY name
ORDER BY 2 DESC;
--dups in playstore
SELECT name, count(*)
FROM app_store_apps
GROUP BY name
ORDER BY 2 DESC;

------------------------------------------------------------------------------------------------
--Final Code Top 10
------------------------------------------------------------------------------------------------
WITH both_stores AS(
	SELECT name
	FROM app_store_apps
	INTERSECT
	SELECT name
	FROM play_store_apps
),

final AS (
SELECT
  DISTINCT(a.name),
  a.price::MONEY AS apple_price,
  p.price::MONEY AS play_price,
  GREATEST(a.price::MONEY, p.price::MONEY)AS highest_price,
  a.primary_genre AS apple_genre,
  p.category AS play_genre,
  a.rating AS apple_rating,
  p.rating AS play_rating,
  LEAST(a.rating, p.rating) AS lowest_rating,
  ROUND(ROUND(LEAST(a.rating, p.rating) * 4) / 4.0,2) AS rating,
-- Calculate app longevity in years based on the lower rating, rounded to the nearest 0.25 (each 0.25 adds 0.5 years)
  ROUND(1 + ((ROUND(LEAST(a.rating, p.rating) * 4) / 4.0) * 2),2) AS longevity_years,
-- I used 90k instead of 100k (we only used app that appear in both stores) because of 1k monthly rights fee
  ROUND(1 + ((ROUND(LEAST(a.rating, p.rating) * 4) / 4.0) * 2),2) ::MONEY AS total_profit
FROM both_stores bs 
LEFT JOIN app_store_apps a
   ON bs.name = a.name
LEFT JOIN play_store_apps p
  ON a.name = p.name
 )

SELECT name,
	   highest_price AS price,
	   apple_rating,
	   play_rating,
	   rating,
	   longevity_years,
	   (total_profit * 9000) * 12 AS total_profit
FROM final
WHERE highest_price::numeric = 0 AND rating >= 4.5
ORDER BY total_profit DESC
LIMIT 10;
