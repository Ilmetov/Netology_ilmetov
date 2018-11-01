
SELECT ('ФИО:  Ильметов Алексей Владимирович');

-- используя функцию определения размера таблицы, вывести top-5 самых больших таблиц базы

SELECT tt.table_name,
 pg_total_relation_size('"' || table_schema || '"."' || table_name || '"')
FROM information_schema.tables tt where tt.table_catalog = 'postgres' order by 2 DESC LIMIT 5;

--специфические функции postgres
-- array_agg: собрать в массив все фильмы, просмотренные пользователем (без повторов)
SELECT userID, array_agg(movieId) as user_views FROM ratings group by userID;

-- таблица user_movies_agg, в которую сохраните результат предыдущего запроса

DROP TABLE IF EXISTS user_movies_agg;
SELECT userID, user_views INTO public.user_movies_agg FROM
(SELECT userID, array_agg(movieId) as user_views FROM ratings group by userID) as uw;

select * from public.user_movies_agg;

-- Используя следующий синтаксис, создайте функцию cross_arr оторая принимает на вход два массива arr1 и arr2.
-- Функциия возвращает массив, который представляет собой пересечение контента из обоих списков.
-- Примечание - по именам к аргументам обращаться не получится, придётся делать через $1 и $2.

CREATE OR REPLACE FUNCTION cross_arr (int[], int[])
 RETURNS int[] language sql as
 $FUNCTION$ select array(Select $1 INTERSECT select $2); $FUNCTION$;

-- Сформируйте запрос следующего вида: достать из таблицы всевозможные наборы u1, r1, u2, r2.
-- u1 и u2 - это id пользователей, r1 и r2 - соответствующие массивы рейтингов
-- ПОДСКАЗКА: используйте CROSS JOIN
SELECT agg.userId as u1, agg.userId as u2, agg.array_agg as ar1, agg.array_agg as ar2 from user_movies_agg as agg