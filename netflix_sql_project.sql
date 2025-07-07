
-- check one show
select * from netflix_raw where show_id = 's5023';

-- find duplicate ids
select show_id, count(*) from netflix_raw group by show_id having count(*) > 1;

-- find duplicate titles by type
select title, type, count(*) from netflix_raw group by title, type having count(*) > 1;

-- preview duplicate rows
select * from netflix_raw 
where concat(upper(title), type) in (
  select concat(upper(title), type)
  from netflix_raw
  group by upper(title), type
  having count(*) > 1
)
order by title;

-- keep one row per title-type
with cte as (
  select *, row_number() over(partition by title, type order by show_id) as rn
  from netflix_raw
)
select show_id, type, title, cast(date_added as date) as date_added,
       release_year, rating,
       case when duration is null then rating else duration end as duration,
       listed_in, description
into netflix
from cte
where rn = 1;

-- split genres
select show_id, trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in, ',');

-- split directors
select show_id, trim(value) as director
into netflix_director
from netflix_raw
cross apply string_split(director, ',');

-- split countries
select show_id, trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country, ',');

-- split cast
select show_id, trim(value) as cast_member
into netflix_cast
from netflix_raw
cross apply string_split(cast, ',');

-- fill missing countries using known director-country mapping
insert into netflix_country (show_id, country)
select nr.show_id, m.country
from netflix_raw nr
join (
  select nd.director, nc.country
  from netflix_director nd
  join netflix_country nc on nd.show_id = nc.show_id
  group by nd.director, nc.country
) m on nr.director = m.director
where nr.country is null;

-- set null durations as 'Not Available'
update netflix set duration = 'Not Available' where duration is null;

-- directors with both movie and tv show
select nd.director,
       count(distinct case when n.type = 'Movie' then n.show_id end) as movies,
       count(distinct case when n.type = 'TV Show' then n.show_id end) as shows
from netflix n
join netflix_director nd on n.show_id = nd.show_id
group by nd.director
having count(distinct n.type) = 2;

-- top country with most comedy movies
select top 1 nc.country, count(distinct n.show_id) as total
from netflix n
join netflix_genre ng on n.show_id = ng.show_id
join netflix_country nc on n.show_id = nc.show_id
where n.type = 'Movie' and ng.genre = 'Comedies'
group by nc.country
order by total desc;

-- top movie director by year
with cte as (
  select nd.director, year(n.date_added) as yr, count(*) as total
  from netflix n
  join netflix_director nd on n.show_id = nd.show_id
  where n.type = 'Movie' and n.date_added is not null
  group by nd.director, year(n.date_added)
),
ranked as (
  select *, row_number() over(partition by yr order by total desc, director) as rn
  from cte
)
select * from ranked where rn = 1;

-- avg movie duration by genre
select ng.genre,
       avg(cast(replace(duration, ' min', '') as int)) as avg_mins
from netflix n
join netflix_genre ng on n.show_id = ng.show_id
where n.type = 'Movie' and duration like '%min'
group by ng.genre
order by avg_mins desc;

-- directors with both comedy and horror
select nd.director,
       count(distinct case when ng.genre = 'Comedies' then n.show_id end) as comedy,
       count(distinct case when ng.genre = 'Horror Movies' then n.show_id end) as horror
from netflix n
join netflix_genre ng on n.show_id = ng.show_id
join netflix_director nd on n.show_id = nd.show_id
where n.type = 'Movie' and ng.genre in ('Comedies', 'Horror Movies')
group by nd.director
having count(distinct ng.genre) = 2;

-- check genres for a director
select ng.*
from netflix_genre ng
join netflix_director nd on ng.show_id = nd.show_id
where nd.director = 'Steve Brill'
order by genre;
