-- to Derive the whole table data
select * from netflix_titles 

-- To verify the total number of rows
select 
	COUNT(*) AS TOTAL_CONTENT
FROM netflix_titles



-- To see the different type of the netflix categories
select
	distinct type 
from	netflix_titles

-- TO find all the null values within dataset.
select 
	* from 
netflix_titles 
	where 
type is null or title is null or director is null or cast is null or country is null or date_added is null 
or release_year is null or rating is null or duration is null or listed_in is null or description is null;


---------------------------Business Problems & Solutions----------------------------------------------------
select * from netflix_titles 


--1. Count the number of Movies vs TV Shows
select  type, 
		count(type) as TotalContent 
from 
	netflix_titles		
group by type;



--2. Find the most common rating for movies and TV shows
with Rating_Count as (
select 
	type,
	rating,
	count(*) as RatingCount,
	rank() over (partition by type order by count(*) DESC) as rnk
from 
	netflix_titles
group by	
	type, rating
)
select type, rating, RatingCount from Rating_Count
where rnk = 1



--3. List all movies released in a specific year (e.g., 2020)

--select * from netflix_titles 
select 
	title 
from 
	netflix_titles
where type = 'Movie' and release_year = '2020'


--4. Find the top 5 countries with the most content on Netflix

--select * from netflix_titles

SELECT TOP 5 
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;

--5. Identify the longest movie
--select * from netflix_titles

SELECT TOP 1
    title,
    duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY 
    TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;


	   	  
--6. Find content added in the last 5 years


SELECT title, date_added
FROM netflix_titles
WHERE TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -6, GETDATE())
ORDER BY TRY_CAST(date_added AS DATE) DESC;




--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!


select * from netflix_titles where director like '%Rajiv Chilaka%'
------another way(More Accurate with null values)----------

select 
	nt.title,nt.type,nt.release_year, nt.director
from 
	netflix_titles nt
cross apply string_split(nt.director,',')s
where
		nt.director is not null 
and 
		TRIM(s.value) = 'Rajiv Chilaka'




--8. List all TV shows with more than 5 seasons

select 
	type, duration 
		from netflix_titles
WHERE 
			type = 'TV Show'
AND 
			TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5



--9. Count the number of content items in each genre

select 
	TRIM(L.value), 
	count(nt.show_id) as numberofcontent
	
from 
	netflix_titles nt 
	cross apply string_split(nt.listed_in, ',') L 
where 
	nt.listed_in is not null
	
group by TRIM(L.value)




/*--10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/

SELECT TOP 5
    year_added,
    yearly_content,
    ROUND(yearly_content * 100.0 / SUM(yearly_content) OVER (), 2) AS avg_content_per_year
FROM (
    SELECT
        YEAR(TRY_CAST(nt.date_added AS date)) AS year_added,
        COUNT(*) AS yearly_content
    FROM netflix_titles nt
    CROSS APPLY STRING_SPLIT(nt.country, ',') c
    WHERE nt.country IS NOT NULL
      AND nt.date_added IS NOT NULL
      AND TRIM(c.value) = 'India'
    GROUP BY YEAR(TRY_CAST(nt.date_added AS date))
) y
ORDER BY avg_content_per_year DESC;



--11. List all movies that are documentaries

SELECT 
	nt.title,
	nt.type,
	nt.listed_in
from 
	netflix_titles nt
cross apply string_split(nt.listed_in, ',') l
where	
	nt.type = 'Movie'
	and TRIM(l.value) = 'Documentaries'


--12. Find all content without a director


select * from netflix_titles where director is null



--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select 
	COUNT(DISTINCT nt.show_id) AS NumberOfMovies
	 
from 
	netflix_titles nt 
	cross apply string_split(nt.cast,',') C
where 
	nt.type = 'movie' 
and
	TRIM(C.value) = 'Salman Khan'
	 AND nt.release_year > YEAR(GETDATE()) - 10;






--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.



--
SELECT TOP 10
    TRIM(a.value) AS actor,
    COUNT(DISTINCT nt.show_id) AS movie_count
FROM netflix_titles nt
CROSS APPLY STRING_SPLIT(nt.[cast], ',') a
CROSS APPLY STRING_SPLIT(nt.country, ',') c
WHERE nt.type = 'Movie'
  AND nt.[cast] IS NOT NULL
  AND nt.country IS NOT NULL
  AND TRIM(c.value) = 'India'
  AND TRIM(a.value) <> ''
GROUP BY TRIM(a.value)
ORDER BY movie_count DESC;









/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/








