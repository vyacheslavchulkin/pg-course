-- Создать таблицу codes с следующим содержимым
--
-- Таблица codes
--
-- id |   code   |          desc
-- ----+----------+------------------------
--   1 | A        | Some value
--   2 | A.1      | Some sub value
--   3 | A.1.01   | Some sub sub value
--   4 | A.1.02   | Some sub sub value 2
--   5 | A.1.02.1 | Some sub sub value 2.1
-- В данном случае это иерархический семантический справочник в котором иерархия зашита в семантику самих кодов.

drop table if exists codes;
create table codes
(
  id serial primary key,
  "code" text,
  "desc" text
);

insert into codes (id, code, "desc")
values (1, 'A', 'Some value'),
       (2, 'A.1', 'Some sub value'),
       (3, 'A.1.01', 'Some sub sub value'),
       (4, 'A.1.02', 'Some sub sub value 2'),
       (5, 'A.1.02.1', 'Some sub sub value 2.1');

-- Создать вторую таблицу items с следующей структурой
-- id serial
-- code text
-- display text
-- path jsonb

drop table if exists items;
create table items
(
  id serial primary key,
  code text,
  display text,
  path jsonb
);

-- Сгенерировать и вставить в таблицу items 1000000 значений примерно следующего вида
-- (с фиксированным значением code A.1.02.1)

insert into items (id, code, display)
select i, 'A.1.02.1', 'Some static item num ' || i
from generate_series(1, 1000000) as _(i);

-- Написать запрос который проставит для всех строк из таблицы items в поле path  jsonb объект содержащий значения code
-- и desc всех родителей для значения code
--
-- 	Пример
-- 	Для строки
--
--   id     |   code     |        display                    | path
-- --------+------------+--------------------------------+------
--  1002 | A.1.02.1 | Some static item num 0 |
--
--
-- 	Поле path должно содержать следующее значение
--
--
-- [
--     {
--         "code": "A",
--         "desc": "Some value"
--     },
--     {
--         "code": "A.1",
--         "desc": "Some sub value"
--     },
--     {
--         "code": "A.1.02",
--         "desc": "Some sub sub value 2"
--     }
-- ]

begin;

create temp table temp_paths
(
  code text,
  path jsonb
);

with recursive paths as (
  select regexp_split_to_array(code, '\.') as sub_codes,
         array_length(regexp_split_to_array(code, '\.'), 1) - 1 depth,
         array [jsonb_build_object('code', code, 'desc', "desc")]::jsonb[] as path,
         code current_code
  from codes

  union

  select sub_codes,
         p.depth - 1 as depth,
         array_append(p.path, jsonb_build_object('code', c."code", 'desc', c."desc")) as result,
         current_code
  from paths p
         join codes c on c.code = array_to_string(sub_codes[0:depth], '.')
  where p.depth >= 0
)

insert
into temp_paths (code, path)
select current_code as code, to_jsonb(max(path)) as path
from paths
group by current_code;

create temp table temp_items as
select id, items.code as code, display, tp.path as path
from items
       join temp_paths tp on items.code = tp.code;

update items
set path = temp_items.path
from temp_items
where items.id = temp_items.id;

drop table temp_items;
drop table temp_paths;

commit;
