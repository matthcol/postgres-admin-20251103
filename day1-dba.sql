-- session user dba postgres, database movie
create schema avis; -- owner: postgres

-- sol 1 : movie devient le proprietaire de schema
ALTER SCHEMA avis  OWNER TO movie; -- droits Create + Usage (ALL)

-- sol 1bis:
create schema boxoffice AUTHORIZATION movie;

-- sol 2: 
GRANT USAGE ON SCHEMA avis TO movie;
GRANT CREATE,USAGE ON SCHEMA avis TO movie;
GRANT ALL ON SCHEMA avis TO movie; -- ALL i.e. CREATE + USAGE

-- set a new search_path for user movie
alter user movie set search_path = movie,boxoffice; -- verifiable dans pgadmin4 (propriétes user)


select * from pg_roles;
select * from pg_roles where rolcanlogin;
select rolname,rolcanlogin,rolconfig from pg_roles where rolcanlogin;

-- quelle version
select version();
show server_version;
SHOW server_version_num;
-- file $PGDATA/PG_VERSION

-- vues du catalogue
select * from pg_tables; -- tables (résumé)
select * from pg_class;  -- table (r) + sequence (S) + index (i) + toast (t) + views (v)

select relname, relkind, oid, relfilenode 
from pg_class 
where relowner = 24576
order by relkind, relname;

select relname, relkind, oid, relfilenode 
from pg_class 
-- where relowner = 24576
order by relkind, relname;

select * from pg_database;


create user movieread with login password 'password';














