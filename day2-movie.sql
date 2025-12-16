-- operations et fonctions sur les textes

select "title" || ' (' || "year" || ')' as title_year
from "movie"."movie"
where title = 'The Terminator';

select concat("title", ' (', "year", ')') as title_year
from "movie"."movie"
where title = 'The Terminator';


-- operations sur les nombres

select 
	title, 
	year /  10 as decade, 
	duration / 60.0 as duration_h, 
	duration::decimal / 60 as duration_h2
from movie where year = 1984;


select * from pg_database;

-- operations sur les dates et heures

-- date et heures système
select
	CURRENT_DATE,
	CURRENT_TIME,
	CURRENT_TIME::time without time zone,
	CURRENT_TIMESTAMP,
	CURRENT_TIMESTAMP::timestamp without time zone
;

-- composante d'une donnée temporelle: extract ou date part
-- NB: pas de year, month, day, hour, ....
select 
	name,
	birthdate,
	extract(year from birthdate) as birth_year,
	date_part('year', birthdate) as birth_year2
from person
where extract(year from birthdate) = 1930
;

-- calculs avec des date/time: operators + - ou fonctions data_add, date_substract
-- films de moins de 10 ans
-- personnes nées il y a 50 ans

select '35 days 3 hours'::interval, '50 years':: interval;
select
	name,
	current_date - birthdate as age_days,
	(current_date - '50 years'::interval)::date
from person
where name like 'Sean%';

show datestyle; -- utilisés pour les input et les outputs
-- "ISO, DMY"

insert into person (name, birthdate) values ('John Doe', '2000-01-06'); -- interpréte en ISO
insert into person (name, birthdate) values ('Jane Doe', '05/07/2001'); -- interprété en DMY
select * from person where name like '% Doe';

set datestyle = MDY;
show datestyle;  -- "ISO, MDY"
insert into person (name, birthdate) values ('Betty Doe', '05/07/2001');
select * from person where name like '% Doe'; -- interprété en DMY

-- formats personalisés
-- https://www.postgresql.org/docs/18/functions-formatting.html
select 
	name,
	birthdate,
	to_char(birthdate, 'FMday DD FMmonth YYYY'), -- FM: remove leadin 0 and blanks
	to_char(birthdate, 'TMday DD TMmonth YYYY') -- TM: Translation Mode
from person
where extract(year from birthdate) = 1930;

show lc_time; -- "French_France.1252"


-- réglages postgresql.conf
-- datestyle = 'iso, dmy'
-- intervalstyle = 'postgres'
-- timezone = 'Europe/Paris'


-- tableaux
create table movie_g(
	id serial constraint pk_movie_g primary key,
	title varchar(300) not null,
	year smallint not null,
	genres varchar(20)[]
);

insert into movie_g (title, year, genres) values ('Titanic', 1997, ARRAY['Drame', 'Catastrophe', 'Tragédie']);
insert into movie_g (title, year, genres) values ('House of Dynamite', 2025, ARRAY['Drame', 'Catastrophe', 'Thriller']);
insert into movie_g (title, year) values ('E.T.', 1982);
select * from movie_g;

select * from movie_g where 'Drame' = ANY(genres);
select * from movie_g where genres @> ARRAY['Drame'::varchar];

-- pivot pour voir un genre par ligne
select id, title, unnest(genres) as genre
from movie_g; 

select distinct unnest(genres) as genre
from movie_g;

-- expression reguliere
select *
from movie
where title ~* '^star( wars?| in)';