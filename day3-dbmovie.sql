select distinct media_type
from media;
-- "movie"
-- "short"
-- "tvEpisode"
-- "tvMiniSeries"
-- "tvMovie"
-- "tvPilot"
-- "tvSeries"
-- "tvShort"
-- "tvSpecial"
-- "video"
-- "videoGame"

select
	count(distinct media_type) as nb_distinct_value,
	count(media_type) as nb_value,
	count(distinct media_type)::real / count(media_type) as selectivite
from media;

select *
from media
where 
	media_type = 'movie'
; -- avec index btree : bitmap index scan

create index idx_media_type on media(media_type); -- default BTREE 

select * from pg_indexes where schemaname = 'movie';

select * from media where release_year between  1970 and 1979
	-- release_year = 1974
	
;	


drop index idx_media_year;
create index idx_media_year on media(release_year); -- btree
create index idx_media_year on media using brin (release_year);


select * 
from pg_stats
where tablename = 'media';

select * 
from pg_stats
where tablename = 'person';

select count(distinct release_year) from media;

analyse media;

analyse verbose media;


-- indexes implicites: contrainte unique

-- cas particulier des clés
select 
	pe.name,
	-- k.*
	m.title
from 
	person pe
	join known_for k on pe.id = k.person_id
	join media m on k.media_id = m.id
where pe.id = 125;


select 
	pe.name,
	m.title, m.release_year,
	pl.character
from 
	person pe
	join play pl on pe.id = pl.actor_id
	join media m on pl.media_id = m.id
where 
	-- pe.id = 125
	-- pe.name = 'Sean Connery'
	-- pe.name = 'sean connery'
	-- pe.name like 'Sean %'
	-- pe.name ilike 'sean connery'
	-- pe.name ~ 'Sean Connery'
	lower(pe.name) = 'sean connery'
order by m.release_year;

select 
	pl.ordering,
	pe.name,
	m.title, m.release_year,
	pl.character
from 
	person pe
	join play pl on pe.id = pl.actor_id
	join media m on pl.media_id = m.id
where 
	-- m.id = 55928
	m.title = 'Dr. No'
order by pl.ordering;

-- indexer les clés étrangères de play
create index idx_play_actor on play(actor_id); -- pour la filmographie d'un acteur
create index idx_play_media on play(media_id);  -- pour le casting d'un media

-- index de type texte
drop index idx_person_name;
-- solution 0
create index idx_person_name on person(name); -- ok si recherche exacte avec la bonne casse
-- solution 3
create index idx_person_name on person(name text_pattern_ops);  -- pg12+
-- solution 5
create index idx_person_name on person(lower(name));



-- => solutions
-- 	1 - collation
-- 	2 - index de type GIN (plusieurs mots) + extension pg_trgm (CI): ~*, ilike
-- 	3 - classe d'operateur text_pattern_ops (like partiel)
-- 	4 - recherche full texte: index + langue : operateurs dédiés: @@
-- 	5 - index de fonction (champs calculé)

-- solution 4
CREATE INDEX idx_movie_title_fts ON media USING gin(to_tsvector('english', title));
select * from media
where to_tsvector('english', title) @@ plainto_tsquery('english', 'star');

select to_tsvector('english', 'STAR WARS: THE LAST JEDI');
-- "'jedi':5 'last':4 'star':1 'war':2"

select
	pe.id, pe.name, -- pe.name est en DF avec la clé pe.id
	count(m.id) as movie_count,
	min(m.release_year) as first_year,
	max(m.release_year) as last_year
from
	person pe
	left join play pl on pe.id = pl.actor_id
	left join media m on pl.media_id = m.id
where 
	lower(pe.name) in (
		'sean connery',
		'bruce willis',
		'demi moore',
		'benoît poelvoorde',
		'steve mcqueen'
	)
group by pe.id -- ,pe.name
;

-- CTE
with person_selection as (
	select *
	from person
	where lower(name) in (
		'sean connery',
		'bruce willis',
		'demi moore',
		'benoît poelvoorde',
		'steve mcqueen'
	)
), filmography_actor as (
	select
		 pe.id, 
		 pe.name,
		 pe.birth_year,
		count(m.id) as movie_count_a,
		min(m.release_year) as first_year_a,
		max(m.release_year) as last_year_a
	from 
		person_selection pe
		left join play pl on pe.id = pl.actor_id
		left join media m on pl.media_id = m.id
	group by pe.id, pe.name, pe.birth_year
), filmography_director as (
	select
		pe.id, 
		count(m.id) as movie_count_d,
		min(m.release_year) as first_year_d,
		max(m.release_year) as last_year_d
	from 
		person_selection pe
		left join direct pl on pe.id = pl.director_id
		left join media m on pl.media_id = m.id
	group by pe.id
)
select *
from 
	filmography_actor fa join filmography_director fd on fa.id = fd.id
order by fa.name
;

-- vue (logique) : seule la requete est stockee
create or replace view v_movie as
	select 
		id, title, original_title, release_year as year, duration_mn
		, media_type -- pour modif INSERT
	from media
	where media_type = 'movie'
with check option;
-- Avantages:
-- - à jour en temps reel (transactions finies)
-- - simplifie les requetes de niveau supérieur
-- - sécurité:
-- 	- lecture seule pour un user dedié: TODO
-- 	- mise à jour : directe ou programmée avec 1 trigger instead of

select setval('media_id_seq', max(id)) from media; -- TODO: à mieux faire ds le dump

insert into v_movie (title, year) values ('A House of Dynamite', 2025);
insert into v_movie (title, year, media_type) values ('A House of Dynamite', 2025, 'movie');
insert into v_movie (title, year, media_type) values ('A House of Dynamite', 2025, 'series');
select * from v_movie where year = 2025 and title like '%House%';
select * from media where release_year = 2025 and title like '%House%';

grant select on v_movie to movieread;
grant usage on schema movie to movieread;
























