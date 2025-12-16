-- dba sur 1 postgresql 11
create user movie with login password 'password';

-- user movie :
create table public.t(); -- OK by default (not anymore with recent versions)