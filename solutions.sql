-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5


-- 5. Identify the longest movie

SELECT 
	*
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC
--6.find content added in last 5 years--
select * from netflix
where 
    to_date(date_added,'month DD,YYYY')>=current_date-interval '5years'

--7.find all movies/tv shows by director 'rajiv chilaka'--
select title from netflix
where director like '%Rajiv Chilaka%'

--list all tv shows with more than 5 seasons
SELECT *
FROM netflix
where type='TV Show'
and 
 split_part(duration,' ',1)::int > 5


 --9.count the number of content items in each genre--
 select 
 unnest(STRING_TO_ARRAY(listed_in,',')),
 count(*) from netflix
 group by 1

 --10.find each year and the average numbersof content release by india on netflix.
 --return top 5 year with highest avg content release.
SELECT 
    release_year,
    COUNT(show_id) AS india_content_count
FROM (
    SELECT 
        release_year,
        show_id,
        TRIM(unnest(string_to_array(country, ','))) AS country
    FROM netflix
) AS expanded
WHERE country = 'India'
GROUP BY release_year
ORDER BY india_content_count DESC
LIMIT 5;

--or--
select 
 extract(year from to_date(date_added,'Month DD,YYYY')) as year,
 count(*),
 round(
count(*)::numeric/(select count(*) from netflix where country ='India')::numeric * 100
,2)as avg_content_per_year
from netflix
where country = 'India'
group by 1
 
--11.list all the movies that are documentries--
select title,type,listed_in from 
(
select
title,
type,
unnest(string_to_array(listed_in,',')) as listed_in
from netflix
where listed_in='Documentaries'
) as expanded
where type='Movie'

--12.find all the content without a director--
select * from netflix 
where director is null

--13.find how many movies actor 'salman khan' appeared in last 10 years
select count(*) from(select release_year  from netflix
where casts like '%Salman Khan%'
and type='Movie' and release_year>2014) as new

--or--
select * from netflix
where
casts ilike '%Salman Khan%'
and 
release_year>extract(year from current_date)-10

--14.find the top 10 actors who have appeared in the highest number of movies produced in india--
select
unnest(string_to_array(casts,',')) as actors,
count(*) as total_content
from netflix
where country ilike '%india'
group by 1
order by 2 desc
limit 10

--15.categorise the content based on the presence of the keywords 'kill' and 'violence' in the description field.label content containing these keywords as 'bad' and all other content as 'good'.count how many items fall into each category.

with new_table
as
(select *,
case 
when 
description ilike '%kill%' or
description ilike '%violence%' then 'bad_content'
else 'good_content'
end category
from netflix)
select category,
count(*) as total_content
from new_table
group by 1

