SELECT pg_database_size(current_database());
65 517 031


SELECT table_name FROM information_schema.tables WHERE table_schema NOT IN ('information_schema','pg_catalog');

CREATE TABLE holiday_picnic (
     holiday varchar(50), -- строковое значение
     sandwich text[], -- массив
     side text[] [], -- многомерный массив
     dessert text ARRAY, -- массив
     beverage text ARRAY[4] -- массив из 4-х элементов
);

INSERT INTO holiday_picnic VALUES
     ('Labor Day',
     '{"roast beef","veggie","turkey"}',
     '{
        {"potato salad","green salad"},
        {"chips","crackers"}
     }',
     '{"fruit cocktail","berry pie","ice cream"}',
     '{"soda","juice","beer","water"}'
     );

select array_ndims(side) from holiday_picnic ;

select * from information_schema.tables ;