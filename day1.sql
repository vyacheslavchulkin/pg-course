-- Find gaps
-- Дана таблица с числовой последовательностью из которой были удалены некоторые последовательности значений
--
-- Задача - найти все удаленные последовательности
--
-- Входные данные
-- create table gaps (id integer primary key);
-- insert into gaps (id) select x from generate_series(1, 10000) x;
-- delete from gaps where id between 102 and 105;
-- delete from gaps where id between 134 and 176;
-- ** Ожидаемый результат
--
--    | from |  to |
--    |------+-----|
--    |  102 | 105 |
--    |  134 | 176 |

select (id + 1) as "from", (next_id - 1) as "to"
from (select id, lead(id) over (order by id) as next_id
      from gaps) as _
where id + 1 < next_id;

