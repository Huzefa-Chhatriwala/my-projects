-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
-- 2. Find the most common rating for movies and TV shows
-- 3. List all movies released in a specific year (e.g., 2020)
-- 4. Find the top 5 countries with the most content on Netflix
-- 5. Identify the longest movie
-- 6. Find content added in the last 5 years
-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
-- 8. List all TV shows with more than 5 seasons
-- 9. Count the number of content items in each genre
-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
-- 11. List all movies that are documentaries
-- 12. Find all content without a director
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

-- create TABLE netflix(
-- 	show_id	varchar(6),
-- 	type varchar(10),
-- 	title varchar(110),
-- 	director varchar(208),
-- 	casts varchar(800),
-- 	country	varchar(125),
-- 	date_added varchar(50),
-- 	release_year int,
-- 	rating varchar(10),
-- 	duration varchar(15),
-- 	listed_in varchar(80),
-- 	description varchar(250)
-- )

SELECT * FROM netflix;

select count(*) as total_rows from netflix;

select distinct type from netflix;

-- 1. Count the number of Movies vs TV Shows

select type, count(*) as total_count_per_type 
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
select type, rating, rank_type
FROM
(select type ,rating, count(*) as count_rating,
rank() over(partition by type order by count(*) desc) as rank_type
from netflix
group by 1,2
order by 4 asc) as a
where rank_type = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
select title, type, release_year
from netflix
where release_year = 2020 
      and type = 'Movie'

-- 4. Find the top 5 countries with the most content on Netflix
select unnest(string_to_array(country, ',')) as new_country, 
count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

-- 5. Identify the longest movie

select * 
from netflix
where type = 'Movie'
	and duration = (select max(duration) from netflix)
limit 1;

-- anathor method
select * 
from netflix
where type = 'Movie' and duration is not null
order by duration desc
limit 1;

-- 6. Find content added in the last 5 years
select * from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type, director
from netflix
where director ilike '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select * from netflix
where type = 'TV Show' and split_part(duration, ' ',1)::numeric >= 5;

-- another method
SELECT *
FROM netflix
WHERE type = 'TV Show' 
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) >= 5;

-- 9. Count the number of content items in each genre
select unnest(string_to_array(listed_in, ',')) as genre, 
count(show_id) as total_content
from netflix
group by 1
order by 2 desc;

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
WITH expanded_countries AS (
    SELECT 
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
        unnest(string_to_array(country, ',')) AS new_country
    FROM netflix
)
SELECT 
    year, 
    COUNT(*) AS type_count,
	round(count(*)::numeric/(select count(*) from expanded_countries WHERE TRIM(new_country) = 'India')::numeric
	* 100,2) as avg_count_per_year
FROM expanded_countries
WHERE TRIM(new_country) = 'India'
GROUP BY year
ORDER BY type_count desc;

-- another method

SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
    COUNT(*) AS type_count,
	round(count(*)::numeric/(select count(*) from netflix WHERE country ILIKE '%India%')::numeric
	* 100,2) as avg_count_per_year
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY year
ORDER BY type_count desc;

-- 11. List all movies that are documentaries
select * from netflix
where listed_in ilike '%documentaries%';

-- 12. Find all content without a director
select * from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix 
where casts ilike '%salman khan%'
	and release_year > EXTRACT(YEAR FROM current_date) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select unnest(string_to_array(casts, ',')) AS actors,
count(*) as total_content
from netflix
where country ilike '%India%' and type = 'Movie'
group by 1
order by 2 desc;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

with new_table as(
SELECT 
    title, 
    description,
    CASE
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END category
FROM netflix
)
select category, count(*) as total_content
from new_table 
group by category;




