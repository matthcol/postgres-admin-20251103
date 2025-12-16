SELECT rolname, rolpassword FROM pg_authid where rolpassword is not null; 

SET password_encryption = 'md5';
create user user_with_old_passwd with login password 'password';
-- WARNING:  setting an MD5-encrypted password
-- CREATE ROLE

SELECT rolname, rolpassword FROM pg_authid where rolpassword is not null; 
-- "user_with_old_passwd"	"md53628ba38c3094cb2442aa30dbedda79e"

SET password_encryption = 'SCRAM-SHA-256';
alter user user_with_old_passwd password 'password';
SELECT rolname, rolpassword FROM pg_authid where rolpassword is not null; 

-- gestion de la casse des identifiants

create schema casse;
set search_path = casse;

-- identifiants non quotés
create table Magasin (
	Name varchar(10)
);

create table "Article" (
	"Name" varchar(10)
);

create table "rayon" (
	"name" varchar(10)
);

select name from magasin;
select NAME from MAGASIN;

-- select name from article;
-- select Name from Article;
select "Name" from "Article";

select name from rayon;
select Name from Rayon;
select * from pg_tables where schemaname = 'casse';
select * from pg_class;

-- colonnes d'une table:
set search_path = movie;
SELECT attname AS column_name,
       format_type(atttypid, atttypmod) AS data_type,
       attnum AS position,
       attnotnull AS not_null
FROM pg_attribute
WHERE attrelid = 'movie'::regclass
  AND attnum > 0  -- Exclure les colonnes système
  AND NOT attisdropped  -- Exclure les colonnes supprimées
ORDER BY attnum;


select * 
from information_schema.columns
where table_name = 'movie'
order by ordinal_position;

