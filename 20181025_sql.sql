SELECT
  userId, movieId, rating,
  ROW_NUMBER() OVER (PARTITION BY userId ORDER BY rating DESC) as movie_rank
FROM (
    SELECT DISTINCT
        userId, movieId, rating
    FROM ratings
    WHERE userId <>1 LIMIT 1000
) as sample
ORDER BY
    userId,
    rating DESC,
    movie_rank
LIMIT 100;


SELECT userId, movieId, rating,
    SUM(rating) OVER (PARTITION BY userId) as strange_rating_metric
FROM (SELECT DISTINCT userId, movieId, rating FROM ratings WHERE userId <>1 LIMIT 1000) as sample
ORDER BY userId, rating DESC
LIMIT 50;


SELECT userId, movieId, rating,
    rating - AVG(rating) OVER (PARTITION BY userId) rating_deviance_simplex,
    rating - SUM(rating) OVER (PARTITION BY userId) /COUNT(rating) OVER (PARTITION BY userId) as rating_deviance_complex
FROM (SELECT DISTINCT userId, movieId, rating FROM ratings WHERE userId <>1 LIMIT 1000) as sample
ORDER BY userId, rating DESC
LIMIT 20;


SELECT userId, movieId, rating,
    FIRST_VALUE(movieId) OVER (PARTITION BY userId ORDER BY RATING) top_content,
    last_value(movieId) OVER (PARTITION BY userId ORDER BY RATING) bottom_content,
    nth_value(movieId, 5) OVER (PARTITION BY userId ORDER BY RATING) r_nth,
    lag(movieId, 5) OVER (PARTITION BY userId ORDER BY RATING) r_lag
FROM (SELECT DISTINCT userId, movieId, rating FROM ratings WHERE userId <>1 LIMIT 1000) as sample
ORDER BY userId, rating ASC
LIMIT 15;