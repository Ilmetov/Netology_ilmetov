SELECT 'ФИО: Ильметов Алексей Владимирович';

--1.1 SELECT , LIMIT - выбрать 10 записей из таблицы rating

select * from public.ratings limit 10 ;
--Для всех дальнейших запросов выбирать по 10 записей 

--1.2 WHERE, LIKE - выбрать из таблицы links всё записи, у которых imdbid оканчивается на "42", а поле movieid между 100 и 1000

select * from public.links l where l.imdbid like '%42' and movieid between 100 and 1000 limit 10;

 --2.1 INNER JOIN выбрать из таблицы links все imdb_id, которым ставили рейтинг 5

select l.imdbid from public.links l
join public.ratings ra on l.movieid = ra.movieid
where ra.rating = 5 limit 10;

--3.1 COUNT() Посчитать число фильмов без оценок

select count(l.movieid) from public.links l
left join public.ratings ra on  l.movieid = ra.movieid
where ra.rating is null limit 10;

--3.2 GROUP BY, HAVING вывести top-10 пользователей, у который средний рейтинг выше 3.5
select userid, AVG(rating) av_r from public.ratings r
group by r.userid
having AVG(rating) > 3.5 
order by AVG(rating) desc limit 10 ;

--4.1 Подзапросы: достать 10 imbdId из links у которых средний рейтинг больше 3.5. 
--Нужно подсчитать средний рейтинг по все пользователям, которые попали под условие - то есть в ответе должно быть одно число.

select l.imdbid from public.links l where l.movieid in (select r.movieid from public.ratings r group by r.movieid having AVG(r.rating)>3.5) limit 10;

--4.2 Common Table Expressions: посчитать средний рейтинг по пользователям, у которых более 10 оценок

with more10 as
(
select userid, count(*) cnt from public.ratings r 
group by r.userid
having count(*) >10
)
select avg(r.rating)
from public.ratings r
join more10 m on r.userid = m.userid ;