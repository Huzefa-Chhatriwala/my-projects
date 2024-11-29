-- Easy Level

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
-- 2. List all albums along with their respective artists.
-- 3. Get the total number of comments for tracks where licensed = TRUE.
-- 4. Find all tracks that belong to the album type single.
-- 5. Count the total number of tracks by each artist.

-- Medium Level

-- 1. Calculate the average danceability of tracks in each album.
-- 2. Find the top 5 tracks with the highest energy values.
-- 3. List all tracks along with their views and likes where official_video = TRUE.
-- 4. For each album, calculate the total views of all associated tracks.
-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.

-- Advanced Level
-- 1. Find the top 3 most-viewed tracks for each artist using window functions.
-- 2. Write a query to find tracks where the liveness score is above the average.
-- 3. Use a WITH clause to calculate the difference between the highest and lowest energy values 
--    for tracks in each album.
-- 4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
-- 5. Calculate the cumulative sum of likes for tracks ordered by the number of views, 
--    using window functions.

-- CREATE TABLE spotify (
--     artist VARCHAR(255),
--     track VARCHAR(255),
--     album VARCHAR(255),
--     album_type VARCHAR(50),
--     danceability FLOAT,
--     energy FLOAT,
--     loudness FLOAT,
--     speechiness FLOAT,
--     acousticness FLOAT,
--     instrumentalness FLOAT,
--     liveness FLOAT,
--     valence FLOAT,
--     tempo FLOAT,
--     duration_min FLOAT,
--     title VARCHAR(255),
--     channel VARCHAR(255),
--     views FLOAT,
--     likes BIGINT,
--     comments BIGINT,
--     licensed BOOLEAN,
--     official_video BOOLEAN,
--     stream BIGINT,
--     energy_liveness FLOAT,
--     most_played_on VARCHAR(50)
-- );

select count(*) from spotify;
select count(DISTINCT(artist)) from spotify;
select count(DISTINCT(album)) from spotify;
select DISTINCT(album_type) from spotify;
select max(duration_min) from spotify;
select min(duration_min) from spotify;
select count(*) from spotify where duration_min = 0;
select * from spotify where duration_min = 0;

-- deleting data where duration_min = 0
delete from spotify where duration_min = 0;

select DISTINCT(most_played_on) from spotify;

-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------

-- Easy Level

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.
select * from spotify where stream >= 1000000000;

-- 2. List all albums along with their respective artists.
select distinct album, artist
from spotify;

-- 3. Get the total number of comments for tracks where licensed = TRUE.
select sum(comments) as total_comments
from spotify
where licensed = 'true';

-- 4. Find all tracks that belong to the album type single.
select * from spotify where album_type ilike 'single';

-- 5. Count the total number of tracks by each artist.
select artist, count(*)
from spotify
group by artist
order by 2 desc;

-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------

-- Medium Level

-- 1. Calculate the average danceability of tracks in each album.
select avg(danceability) as average_danceability, album
from spotify
group by 2;

-- 2. Find the top 5 tracks with the highest energy values.
select track, avg(energy)
from spotify
group by 1
order by 2 desc
limit 5;

-- 3. List all tracks along with their views and likes where official_video = TRUE.
select track, sum(views) as total_views, sum(likes) as total_likes
from spotify
where official_video = 'true'
group by 1
order by 2 desc;

-- 4. For each album, calculate the total views of all associated tracks.
select album, track,sum(views) as total_views
from spotify
group by 1,2;

-- 5. Retrieve the track names that have been streamed on Spotify more than YouTube.
select track, streamed_on_spotify
from
(select track,
	COALESCE(sum(case when most_played_on= 'Youtube' then stream end),0) as streamed_on_youtube, 
	COALESCE(sum(case when most_played_on= 'Spotify' then stream end),0) as streamed_on_Spotify
from spotify 
group by 1)
where streamed_on_Spotify > streamed_on_youtube
	and streamed_on_youtube <> 0;

-------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------

-- Advanced Level

-- 1. Find the top 3 most-viewed tracks for each artist using window functions.
with ranking_artist
as
(
select artist, track, sum(views) as total_views,
dense_rank () over( partition by artist order by sum(views) desc) as rank_
from spotify
group by artist, track
order by artist, rank_
)
select artist, track,total_views, rank_
from ranking_artist
where rank_ < 4;

-- 2. Write a query to find tracks where the liveness score is above the average.
select track, liveness
from spotify
where liveness > (select avg(liveness) from spotify);

-- 3. Use a WITH clause to calculate the difference between the highest and lowest energy values 
--    for tracks in each album.
with new_table as 
(
select album,
max(energy) as highest_energy,
min(energy) as lowest_energy
from spotify
group by 1
)
select album, (highest_energy - lowest_energy) as energy_diff
from new_table ;

-- 4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
select track, energy, liveness, (energy/liveness) as e_t_ol, energy_liveness
from spotify
where energy_liveness > 1.2;

-- 5. Calculate the cumulative sum of likes for tracks ordered by the number of views,
--    using window functions.

SELECT 
	track,
	likes,
	views,
	SUM(likes) OVER (ORDER BY views) AS cumulative_sum
FROM Spotify
ORDER BY cumulative_sum DESC;




