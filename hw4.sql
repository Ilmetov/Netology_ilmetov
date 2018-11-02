
SELECT ('ФИО:  Ильметов Алексей Владимирович');

-- используя функцию определения размера таблицы, вывести top-5 самых больших таблиц базы

SELECT tt.table_name,
 pg_total_relation_size('"' || table_schema || '"."' || table_name || '"')
FROM information_schema.tables tt where tt.table_catalog = 'postgres' order by 2 DESC LIMIT 5;

--специфические функции postgres
-- array_agg: собрать в массив все фильмы, просмотренные пользователем (без повторов)
SELECT userID, array_agg(movieId) as user_views FROM ratings group by userID;

-- таблица user_movies_agg, в которую сохраните результат предыдущего запроса
select userid,movieid,rating,"timestamp" INTO public.small_ratings from (SELECT * FROM ratings LIMIT 10000) as t;

--select count(*) from small_ratings;

DROP TABLE IF EXISTS user_movies_agg;
SELECT userID, user_views INTO public.user_movies_agg FROM
(SELECT userID, array_agg(movieid) as user_views FROM small_ratings group by userID) as t;

select count(*) from public.user_movies_agg;

-- Используя следующий синтаксис, создайте функцию cross_arr оторая принимает на вход два массива arr1 и arr2.
-- Функциия возвращает массив, который представляет собой пересечение контента из обоих списков.
-- Примечание - по именам к аргументам обращаться не получится, придётся делать через $1 и $2.

CREATE OR REPLACE FUNCTION cross_arr (bigint[], bigint[])
 RETURNS bigint[] language sql as
 $FUNCTION$ select array(Select $1 INTERSECT select $2); $FUNCTION$;

-- Сформируйте запрос следующего вида: достать из таблицы всевозможные наборы u1, r1, u2, r2.
-- u1 и u2 - это id пользователей, r1 и r2 - соответствующие массивы рейтингов
-- ПОДСКАЗКА: используйте CROSS JOIN
;

-- Оберните запрос в CTE и примените к парам <ar1, ar2> функцию CROSS_ARR, которую вы создали
-- вы получите триплеты u1, u2, crossed_arr
-- созхраните результат в таблицу common_user_views
with cross_rating as(SELECT
agg1.userid as u1,
agg2.userid as u2,
agg1.user_views as ar1,
agg2.user_views as ar2
from user_movies_agg as agg1
cross join user_movies_agg as agg2)
select u1, u2, cross_arr(ar1,ar2) from cross_rating;

--пробуем вставить с использованием with
DROP TABLE IF EXISTS common_user_views;
WITH cross_rating as (
SELECT
agg1.userid as u1,
agg2.userid as u2,
agg1.user_views as ar1,
agg2.user_views as ar2
from user_movies_agg as agg1
cross join user_movies_agg as agg2
)select u1, u2, cross_arr(ar1,ar2) as ar_cross INTO public.common_user_views FROM cross_rating;

select * from public.common_user_views;

/*
SELECT
count(*)
from user_movies_agg as agg1
cross join user_movies_agg as agg2 ;
63 297 936 */

-- Создайте по аналогии с cross_arr функцию diff_arr, которая вычитает один массив из другого.
-- Подсказка: используйте оператор SQL EXCEPT.
CREATE OR REPLACE FUNCTION diff_arr (bigint[], bigint[])
 RETURNS bigint[] language sql as
 $FUNCTION$ select array(Select $1 EXCEPT select $2); $FUNCTION$;



-- Сформируйте рекомендации - для каждой пары посоветуйте для u1 контент, который видел u2, но не видел u1 (в виде массива).
-- Подсказка: нужно заджойнить user_movies_agg и common_user_views и применить вашу функцию diff_arr к соответствующим полям.
-- с векторами фильмов
--тут не понял, почему в подсказке был cross join? по идее у нас уже есть cross. т.е. оптимальнее наверное
--было положить в common_user_views сразу и id обоих юзеров и пересечение, и каждый массив отдельно
--либо просто join
SELECT cuv.u1, cuv.u2, diff_arr (uma.user_views, cuv.ar_cross)
FROM common_user_views cuv JOIN user_movies_agg uma on cuv.u2 = uma.userid LIMIT 10;

--или если положить всё в одну таблицу
SELECT cuv.u1, cuv.u2, diff_arr (cuv.ur2, cuv.ar_cross)
FROM common_user_views cuv LIMIT 10;
