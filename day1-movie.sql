select count(*) as nb_movie from movie;
select count(*) as nb_person from person;

show search_path; -- """$user"", public"
set search_path = public; -- changement dans la session courante
show search_path; -- public
select count(*) as nb_person from person; -- ERROR:  relation "person" does not exist
select count(*) as nb_person from movie.person;

create table public.t(); -- ERROR:  permission denied for schema public
create table avis.t(); -- OK si movie à les droites CREATE + USAGE

-- schema boffice with owner movie
create table boxoffice.score(
	id serial constraint pk_score primary key, -- AUTO: create sequence score_id_seq
	public_count int,
	recette int,
	movie_id int
);
select * from score; -- KO
select * from boxoffice.score; -- OK

set search_path = movie,boxoffice;
set search_path = "$user",boxoffice;
show search_path; -- setting for this session only
select * from score;
select count(*) from movie;

-- equivalences:
-- type serial : sequence created auto + colonne de type int (0 à 2 milliards)
-- type bigserial : sequence created auto + colonne de type bigint (0 à 9 milliards de milliards)
-- type smallserial : sequence created auto + colonne de type smallint (0 à 32k)

drop table cobaye_seq;
create table cobaye_seq(
	id smallserial,
	label varchar(10)
);

insert into cobaye_seq (label) values('cobaye 1');
insert into cobaye_seq (label) values('cobaye #2');
select * from cobaye_seq;

select nextval('cobaye_seq_id_seq'); -- plein de fois => 14
insert into cobaye_seq (label) values('cobaye #3');
select * from cobaye_seq;
select currval('cobaye_seq_id_seq'); -- dernier id generé cette session

-- better DML: insert ... returning (idem avec update ou delete)
insert into cobaye_seq (label) values('cobaye #4') returning id;


select setval('cobaye_seq_id_seq', 1);
select nextval('cobaye_seq_id_seq'); -- 2 à 14
insert into cobaye_seq (label) values('cobaye #5') returning id;
select * from cobaye_seq;
select 2^15 -1;
select setval('cobaye_seq_id_seq', 32767);
insert into cobaye_seq (label) values('cobaye #6') returning id; -- ERROR:  nextval: reached maximum value of sequence "cobaye_seq_id_seq" (32767) 
select nextval('cobaye_seq_id_seq'); -- ERROR:  nextval: reached maximum value of sequence "cobaye_seq_id_seq" (32767) 

alter sequence cobaye_seq_id_seq restart with 1; 
select nextval('cobaye_seq_id_seq'); -- 1

create sequence custom_seq 
	start with 2
	INCREMENT by 10
	MINVALUE 1 MAXVALUE 20000
	CACHE 10;
select nextval('custom_seq');

-- identity: 'always' ou 'by default'
drop table cobaye_identity;
create table cobaye_identity(
	id smallint generated always as identity primary key,
	label varchar(10)
);

insert into cobaye_identity (label) values('cobaye #1') returning id;
insert into cobaye_identity (label) values('cobaye #2') returning id;
select * from cobaye_identity;

-- insert into cobaye_identity (id, label) values(4, 'cobaye #2') returning id;
-- ERROR:  Column "id" is an identity column defined as GENERATED ALWAYS.cannot insert a non-DEFAULT value into column "id" 

-- force anyway
insert into cobaye_identity (id, label) 
OVERRIDING SYSTEM VALUE
values(4, 'cobaye #2') returning id; 

insert into cobaye_identity (label) values('cobaye ##') returning id;  -- 3 OK puis 4: KO

-- Conclusion: réaligner les sequences en cas d'écriture directe des ids

CREATE TABLE produits (
    id INTEGER GENERATED ALWAYS AS IDENTITY (
        START WITH 1000
        INCREMENT BY 10
        MINVALUE 1000
        MAXVALUE 999999
        CACHE 20
    ) PRIMARY KEY,
    libelle VARCHAR(200),
    prix DECIMAL(10,2)
);

delete from cobaye_seq where id % 2 = 0;
insert into cobaye_seq (label) values('cobaye #') returning *; 

delete from play where actor_id % 2 = 0;
vacuum full play;