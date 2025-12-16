grant create,usage on schema public to movie;

-- shortcut grant
-- grant usage on schema public to movie; (default)
grant select on all tables in schema public to movieread;