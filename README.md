# Netflix Movies and TV Shows Data Analysis using SQL
![](https://github.com/krunalpatoliya7/Netflix_Project_Analysis/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
select  type, 
		count(type) as TotalContent 
from 
	netflix_titles		
group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql

--select * from netflix_titles 
select 
	title 
from 
	netflix_titles
where type = 'Movie' and release_year = '2020'
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT TOP 5 
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM netflix_titles
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql

SELECT TOP 1
    title,
    duration
FROM netflix_titles
WHERE type = 'Movie'
ORDER BY 
    TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) DESC;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT title, date_added
FROM netflix_titles
WHERE TRY_CAST(date_added AS DATE) >= DATEADD(YEAR, -6, GETDATE())
ORDER BY TRY_CAST(date_added AS DATE) DESC;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
select 
	nt.title,nt.type,nt.release_year, nt.director
from 
	netflix_titles nt
cross apply string_split(nt.director,',')s
where
		nt.director is not null 
and 
		TRIM(s.value) = 'Rajiv Chilaka'
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select 
	type, duration 
		from netflix_titles
WHERE 
			type = 'TV Show'
AND 
			TRY_CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select 
	TRIM(L.value), 
	count(nt.show_id) as numberofcontent
	
from 
	netflix_titles nt 
	cross apply string_split(nt.listed_in, ',') L 
where 
	nt.listed_in is not null
	
group by TRIM(L.value)
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql

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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql

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
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * from netflix_titles where director is null

```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql

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
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
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
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH Categorized AS (
    SELECT
        CASE
            WHEN description IS NOT NULL
                 AND (
                      PATINDEX('%[^a-z]kill[^a-z]%', LOWER(' ' + description + ' ')) > 0
                   OR PATINDEX('%[^a-z]violence[^a-z]%', LOWER(' ' + description + ' ')) > 0
                 )
            THEN 'Bad'
            ELSE 'Good'
        END AS content_category
    FROM netflix_titles
)	
SELECT content_category, COUNT(*) AS total_items
FROM Categorized
GROUP BY content_category;

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Krunal J Patoliya

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!


Thank you for your support, and I look forward to connecting with you!


