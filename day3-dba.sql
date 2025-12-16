-- database
vacuum; 
analyze;
vacuum analyze;

vacuum full;

-- niveau table
vacuum full analyze movie.media;

-- reglages du vaccum/analyze auto: régalages par défaut (cf postgresql.conf, chapitre VACUUM)
-- VACUUM automatique se déclenche quand :
-- 50 + (20% × nombre de tuples) ont été modifiés/supprimés
-- ANALYZE automatique se déclenche quand :
-- 50 + (10% × nombre de tuples) ont été modifiés

-- extensions
SELECT * FROM pg_extension; -- installées
SELECT * FROM pg_available_extensions; -- disponibles: pg_stat_statements


shared_preload_libraries = 'pg_stat_statements'		# (change requires restart)

create extension pg_stat_statements; -- pour chaque base
SELECT * FROM pg_extension; -- ok elle est là :)

select * from pg_stat_statements;

SELECT 
    query,
    calls,
    round(mean_exec_time::numeric, 2) AS avg_time_ms,
    round(total_exec_time::numeric, 2) AS total_time_ms,
    round((100 * total_exec_time / sum(total_exec_time) OVER ())::numeric, 2) AS percent_time
FROM pg_stat_statements
where userid = 24576
ORDER BY mean_exec_time DESC
LIMIT 20;

SELECT 
    u.usename AS user,
	 u.usesysid,
    count(*) AS nb_queries,
    sum(calls) AS total_calls,
    round(sum(total_exec_time)::numeric, 2) AS total_time_ms
FROM pg_stat_statements s
JOIN pg_user u ON u.usesysid = s.userid
GROUP BY u.usename,  u.usesysid
having u.usename = 'movie'
ORDER BY total_time_ms DESC;

SELECT pg_stat_statements_reset();

SHOW block_size; -- pas reglable (à la compilation)


create role fan1;
create user fan2; -- can login = true

create role fan3 with login;
create user fan4 with login;

alter user fan4 with password 'password_super:)';
alter user fan4 with nologin;


create role r_movie_reader;
grant select on movie.v_movie to r_movie_reader;
grant usage on schema movie to r_movie_reader;

grant r_movie_reader to fan2;
alter user fan2 with password 'password';

revoke  r_movie_reader from fan2;
revoke select on movie.v_movie from r_movie_reader;
revoke usage on schema movie from r_movie_reader;
drop role  r_movie_reader;

-- role non hérité (non implicite)
drop user fan2;
CREATE user fan2 with NOINHERIT password 'password';
create role r_movie_reader;
grant select on movie.v_movie to r_movie_reader;
grant usage on schema movie to r_movie_reader;
grant r_movie_reader to fan2;


-- sessions et verrous
select * from pg_stat_activity;
select * from pg_locks;

select pg_terminate_backend(26112); -- mechant: fin session
select pg_cancel_backen(pid); -- gentil: fin transaction



