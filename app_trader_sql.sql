SELECT *
FROM play_store_apps
where genres like 'family'

--dups in playstore
select name, count(*)
from play_store_apps
group by name
order by 2 DESC

--dups in playstore
select name, count(*)
from app_store_apps
group by name
order by 2 DESC
------------------------------------------------------------------------------------------------
--Jenny's code
WITH both_stores AS(
	SELECT name
	FROM app_store_apps
	INTERSECT
	SELECT name
	FROM play_store_apps),

final_both AS (SELECT name, price::money, rating, aps.primary_genre AS genre
FROM both_stores
LEFT JOIN app_store_apps aps USING (name)
WHERE price <1 AND rating >4
UNION
SELECT name, price::money, rating, ps.genres
FROM both_stores
LEFT JOIN play_store_apps as ps USING (name)
WHERE price LIKE  '0' AND rating >4
)

select *
from final_both



------------------------------------------------------------------------------------------------
SELECT
  Distinct(a.name),
  a.price::text AS apple_price,
  p.price::text AS play_price_raw,
  CASE 
    WHEN p.price = 'Free' THEN '0'
    ELSE CAST(p.price AS text)
  END AS play_price,
  GREATEST(a.price::text, 
           CASE 
             WHEN p.price = 'Free' THEN '0' 
             ELSE CAST(p.price AS text) 
           END) AS final_price,
  LEAST(a.rating, p.rating) AS lowest_rating,
  a.primary_genre,
  p.category AS android_category,
  a.content_rating AS apple_content_rating,
  p.content_rating AS android_content_rating
FROM app_store_apps a
JOIN play_store_apps p
  ON LOWER(a.name) = LOWER(p.name) 
WHERE a.rating IS NOT NULL 
  AND p.rating IS NOT NULL;