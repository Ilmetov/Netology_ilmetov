--вывести количество уникальных клиентов для каждого сотрудника

select e.first_name, e.last_name, count(distinct o.customer_id) 
from employees e 
join orders o on e.employee_id = o.employee_id
group by 1,2;

--вывести количество продуктов в разрезе стран поставщиков упорядочив по убыванию
select s.country, count(p.product_id) 
from suppliers s 
join products p on s.supplier_id = p.supplier_id
group by 1 
order by 2 desc;

--вывести количество продуктов для тех категорий, для которых в перечне продуктов более 2 наименований
select c.category_name, count(p.product_id) 
from categories c
join products p on c.category_id = p.category_id
group by 1
having count(p.product_id) > 2 
order by 2 desc;

--вывести количество заказов в разрезе месяца для сотрудников, которые никому не подчиняются
select e.first_name, e.last_name, to_char(order_date, 'YYYY-MM'), count (o.order_id) 
from orders o
join employees e on o.employee_id = e.employee_id
where e.reports_to is null
group by 1,2,3
order by 3;

--для этого же сотрудника вывести сумму заказов накопительным итогом в разрезе каждого месяца
with sum_emp as (
select o.employee_id, to_char(o.order_date, 'YYYY-MM') as m, sum (od.unit_price * od.quantity) ord_sum from order_details od 
join orders o on od.order_id = o.order_id
group by 1,2)

select e.first_name, e.last_name, se.m, se.ord_sum, sum (se.ord_sum) over (partition by e.employee_id order by se.m)  
from sum_emp se
join employees e on se.employee_id = e.employee_id
where e.reports_to is null
order by 3
;

--вывести топ 5 сотрудников, которые чаще всего в своих заказах делали скидку
--в итоговом результате также вывести максимальное и минимальное количество скидок среди всех (!) сотрудников
with dis as (select e.last_name, e.first_name, 
sum (case when od.discount > 0 then 1 else 0 end) as dis_cnt
--max(sum (case when od.discount > 0 then 1 else 0 end) over (partition by e.employee_id))  
from 
order_details od 
join orders o on od.order_id = o.order_id
join employees e on o.employee_id = e.employee_id
group by 1,2)

select last_name, first_name, dis_cnt, max (dis_cnt) over (), min (dis_cnt) over ()
from dis
order by 3 desc
limit 5;


--вывести топ 5 сотрудников с наилучшим средним временем обработки заказов за всё время
select e.last_name, e.first_name, avg (o.shipped_date - o.order_date ) from 
orders o 
join employees e on o.employee_id = e.employee_id 
group by 1,2
order by 3 asc
limit 5;

--вывести в разрезе каждого месяца (относительно даты заказа) 5 наиболее популярных продуктов 
--популярность меряем по стоимости товара в заказах

with prod_sum as 
(select 
to_char(o.order_date, 'YYYY-MM') as m, 
p.product_name as pd_name, 
sum (od.quantity * od.unit_price) as summ 
from order_details od 
join products p on od.product_id = p.product_id
join orders o on od.order_id = o.order_id
group by 1,2),

 rank_prod as 
(select m, pd_name, summ, rank() over (partition by m order by summ desc) as rang from prod_sum )

select m, pd_name, summ from rank_prod where rang <=5;

--вывести сотрудников у которых есть заказы, время обработки которых превышает среднее по всем сотрудникам
--в разрезе каждого месяца
with order_len as (select 
to_char(o.order_date, 'YYYY-MM') as m,
o.employee_id,
(o.shipped_date - o.order_date) days,
avg (o.shipped_date - o.order_date) over (partition by to_char(o.order_date, 'YYYY-MM')) as avg_days
from
orders o)

select distinct ol.m, e.first_name, e.last_name from order_len ol 
join employees e on e.employee_id = ol.employee_id where days > avg_days ;

--вывести для каждого сотрудника идентификатор заказа с наиболее быстрым оформлением заказа в разрезе каждого месяца
with order_min as 
(select to_char(o.order_date, 'YYYY-MM') as m,
e.first_name,
e.last_name,
o.order_id, 
(o.shipped_date - o.order_date) days,
min (o.shipped_date - o.order_date) over (partition by to_char(o.order_date, 'YYYY-MM'),o.employee_id) as min_day 
from orders o 
join employees e on o.employee_id = e.employee_id )
select
m,
first_name,
last_name,
order_id
from order_min where min_day = days
;
