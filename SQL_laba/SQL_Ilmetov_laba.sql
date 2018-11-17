/*
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS employee;

--creating tables

CREATE TABLE department (
    id integer NOT NULL,
    "name" varchar(100)
);

create table employee (
	id integer not null,
	department_id integer,
	chief_doc_id integer,
	"name" varchar(100),
	num_public integer
);

ALTER TABLE ONLY department
ADD CONSTRAINT pk_department PRIMARY KEY (id);

ALTER TABLE ONLY employee
ADD CONSTRAINT pk_employee PRIMARY KEY (id);   
 
ALTER TABLE ONLY employee
ADD CONSTRAINT fk_employee_department FOREIGN KEY (department_id) REFERENCES department;

--inserting values
INSERT INTO department VALUES ('1', 'Therapy'), ('2', 'Neurology'), ('3', 'Cardiology'), ('4', 'Gastroenterology'), ('5', 'Hematology'), ('6', 'Oncology');

insert into employee values
('1', '1', '1', 'Kate', 4), ('2', '1', '1', 'Lidia', 2), ('3', '1', '1', 'Alexey', 1), ('4', '1', '2', 'Pier', 7), ('5', '1', '2', 'Aurel', 6),
('6', '1', '2', 'Klaudia', 1), ('7', '2', '3', 'Klaus', 12), ('8', '2', '3', 'Maria', 11), ('9', '2', '4', 'Kate', 10), ('10', '3', '5', 'Peter', 8),
('11', '3', '5', 'Sergey', 9), ('12', '3', '6', 'Olga', 12), ('13', '3', '6', 'Maria', 14), ('14', '4', '7', 'Irina', 2), ('15', '4', '7', 'Grit', 10),
('16', '4', '7', 'Vanessa', 16), ('17', '5', '8', 'Sascha', 21), ('18', '5', '8', 'Ben', 22), ('19', '6', '9', 'Jessy', 19), ('20', '6', '9', 'Ann', 18);

*/
--selecting
--2.1
--Вывести список названий департаментов и количество главных врачей в каждом из этих департаментов
select d."name", count(distinct chief.id) from employee e 
join department d on e.department_id = d.id
join employee chief on e.chief_doc_id = chief.id
group by 1;

--2.2.
--Вывести список департамент id в которых работаю 3 и более сотрудника
select d."name" from department d
join employee e on d.id = e.department_id 
group by d."name"
having count (e.id) >= 3 ;

--2.3
--Вывести список департамент id с максимальным количеством публикаций
with pub as (
select d.id, sum(e.num_public) sum_pub, max(sum(num_public)) over () as max_pub
from department d
join employee e on d.id = e.department_id 
group by d.id )

select id from pub where sum_pub = max_pub
;

--2.4
--Вывести список имен сотрудников + департамент с минимальным количеством публикаций в своем департаментe
with min_pub as(
select e."name" as e_name, d."name" as d_name, e.num_public as num_pub, min(e.num_public) over (partition by d."name") as min_pub from department d
join employee e on d.id = e.department_id )
select e_name, d_name, num_pub from min_pub where min_pub.num_pub = min_pub ;

--2.5
--Вывести список названий департаментов и среднее количество публикаций для тех департаментов, в которых
--работает более одного главного врача

select d."name" as d_name,  count( distinct e.chief_doc_id )as chief, avg(e.num_public) from department d
join employee e on d.id = e.department_id
group by 1
having count( distinct e.chief_doc_id ) >1;

