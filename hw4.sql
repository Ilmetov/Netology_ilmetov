
SELECT ('ФИО:  Ильметов Алексей Владимирович');

-- спользуя функцию определения размера таблицы, вывести top-5 самых больших таблиц базы

SELECT tt.table_name,
 pg_total_relation_size('"' || table_schema || '"."' || table_name || '"')
FROM information_schema.tables tt where tt.table_catalog = 'postgres' order by 2 DESC LIMIT 5;
