select * 
from person
where name = 'Sean Connery'; -- scan complet base si pas d'index

select * 
from person
where id = 125; -- scan index BTREE unique: coût log(n)

-- 
- 1K => 10
- 1M => 20
- 1G => 30

select count(*) from person; -- 13_884_546

select 13884546 / 150;

select * from pg_indexes;
