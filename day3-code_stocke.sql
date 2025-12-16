code stocké (même schema que la data ou autre schema)
- procédure : traitement avec param en IN ou OUT
- fonction: renvoie un resultat, utilisable avec select
		* OK pour effet de bord
- types
- triggers : fonction  trigger déclenché par un event DML

plusieurs langages de programmation possible
* plpgsql (défaut)
* python
* langage C
* langage Java

create function title_year (title varchar, year int) returns varchar
as
$$
begin
	return upper(title) || ' (' || year || ')';
end;
$$ language plpgsql
;

select title_year(title, year)
from v_movie
where year = 1984;

select title_year('E.T.', 1982);

drop function exists_person;
create or replace function exists_person(p_name varchar, p_id int default NULL, p_birthdate date default NULL)
returns boolean
as
$$
declare
	v_person_count int;
begin
	select count(*) into v_person_count from person p
	where p.name = p_name;
	raise notice 'number of persons found: %', v_person_count;
	return v_person_count > 0;
end;
$$ language plpgsql;

select exists_person('Steve McQueen');

select * from person where name = 'Steve';


-- triggers : 2 éléments
-- 1 - fonction trigger
create or replace function fntrg_new_media() returns trigger as
$$
begin
	if NEW.media_type is null then
		NEW.media_type := 'movie';
	end if;
	return NEW;
end;
$$ language plpgsql;

-- 2 : declencheur
create trigger trg_new_media
before insert on media
for each row
execute function fntrg_new_media();

insert into v_movie (title, year) values ('A House of Dynamite', 2025);


