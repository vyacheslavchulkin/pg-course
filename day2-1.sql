-- Task 1 - Largest Organization
-- В таблице со списком огранизаций, найти головную организацию с наибольшим числом отделений (с учетом головной огранизации).
--
-- Входные данные
-- create table organization (
--                               id int,
--                               parent int,
--                               name text
-- );
-- insert into organization (id, parent, name)
-- values (1, null, 'ГКБ 1')
--      ,(2, null, 'ГКБ 2')
--      ,(3, 1, 'Детское отделение')
--      ,(4, 3, 'Правое крыло')
--      ,(5, 4, 'Кабинет педиатра')
--      ,(6, 2, 'Хирургия')
--      ,(7, 6, 'Кабинет 1')
--      ,(8, 6, 'Кабинет 2')
--      ,(9, 6, 'Кабинет 3')
--     Ожидаемый результат
--        | name  | cnt |
--        |-------+-----|
--        | ГКБ 2 |   5 |

with recursive orgs as (
  select *, id head
  from organization
  where parent is null

  union

  select o.*, orgs.head head
  from orgs as orgs
       join organization as o on o.parent = orgs.id
)

select o.name, count(o.id)
from orgs
     join organization o on o.id = orgs.head
group by o.name
limit 1;
