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
*
from
	person pe
	join play pl on pe.id = pl.actor_id
	join media m on pl.media_id = m.id
where 
name in (
	'Sean Connery',
	'Bruce Willis',
	'Demi Moore',
	'Benoît Poelvoorde'
)
;





