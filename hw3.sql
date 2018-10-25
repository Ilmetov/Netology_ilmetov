--аналитические функции
select userid, movieid,rating,
min(rating) over (partition by userid),
max(rating) over (partition by userid),
 ((rating - min(rating) over (partition by userid)) /
  (max(rating) over (partition by userid) - min(rating) over (partition by userid)) ) as normed_rating,
  avg(rating) over (partition by userid) as avg_rating
 from public.ratings
limit 100 ;

--ETL
--EXTRACT
--"ВАША КОМАНДА СОЗДАНИЯ ТАБЛИЦЫ"
sql --host $APP_POSTGRES_HOST -U postgres -c '
  CREATE TABLE keywords (
    movieId bigint,
    tags text
  );'
--"ВАША КОМАНДА ЗАЛИВКИ ДАННЫХ В ТАБЛИЦу";
psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy keywords FROM '/data/keywords.csv' DELIMITER ',' CSV HEADER"

;
--TRANSFORM
--ЗАПРОС1 и ЗАПРОС2
with top_rated as (
select r.movieid, avg(rating) as avg_rating from public.ratings r group by movieid having count(userid)>50
order by avg_rating DESC, r.movieid asc limit 150)
select * from top_rated tr
join public.keywords k on k.movieid = tr.movieid ;

--LOAD
--ЗАПРОС3
with top_rated as (
select r.movieid, avg(rating) as avg_rating from public.ratings r group by movieid having count(userid)>50
order by avg_rating DESC, r.movieid asc limit 150)
select tr.movieid, k.tags as top_rated_tags into top_rated_tags from top_rated tr
join public.keywords k on k.movieid = tr.movieid ;


-- выгрузка данных
--"ВАША КОМАНДА ВЫГРУЗКИ ТАБЛИЦЫ В ФАЙЛ"
    psql --host $APP_POSTGRES_HOST -U postgres -c \
    "\\copy (select * from top_rated_tags) to ''/data/top_rated_tags.tsv'' with delimiter as E''\t''"
