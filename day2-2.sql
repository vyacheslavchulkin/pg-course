-- Task 2 - Materialized path
-- Для таблицы organization добавть колонку pth с типом int[]
--
-- Заполнить колонку path массивом id всех родительских отделений
--
-- Входные данные
-- Таблица огранизаций
--
-- select * from organization;
--     | id | parent | name              |
--     |----+--------+-------------------|
--     |  1 |        | ГКБ 1             |
--     |  2 |        | ГКБ 2             |
--     |  3 |      1 | Детское отделение |
--     |  4 |      3 | Правое крыло      |
--     |  5 |      4 | Кабинет педиатра  |
--     |  6 |      2 | Хирургия          |
--     |  7 |      6 | Кабинет 1         |
--     |  8 |      6 | Кабинет 2         |
--     |  9 |      6 | Кабинет 3         |
--
-- Ожидаемый результат
--     | id | parent | name              | pth     |
--     |----+--------+-------------------+---------|
--     |  1 |        | ГКБ 1             | {}      |
--     |  2 |        | ГКБ 2             | {}      |
--     |  3 |      1 | Детское отделение | {1}     |
--     |  4 |      3 | Правое крыло      | {1,3}   |
--     |  5 |      4 | Кабинет педиатра  | {1,3,4} |
--     |  6 |      2 | Хирургия          | {2}     |
--     |  7 |      6 | Кабинет 1         | {2,6}   |
--     |  8 |      6 | Кабинет 2         | {2,6}   |
--     |  9 |      6 | Кабинет 3         | {2,6}   |

alter table organization
  add column pth int[];

with recursive orgs as (
  select *, array []::int[] parents
  from organization
  where parent is null

  union

  select o.*, array_append(parents, orgs.id) as parents
  from orgs as orgs
       join organization as o on o.parent = orgs.id
)
update organization
set pth = orgs.parents
from orgs
where orgs.id = organization.id;
