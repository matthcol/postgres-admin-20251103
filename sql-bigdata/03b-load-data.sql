-- alternative au script shell 03-load-data.sh

ALTER TABLE aka SET UNLOGGED;
ALTER TABLE direct SET UNLOGGED;
ALTER TABLE have_episode SET UNLOGGED;
ALTER TABLE have_genre SET UNLOGGED;
ALTER TABLE have_profession SET UNLOGGED;
ALTER TABLE known_for SET UNLOGGED;
ALTER TABLE play SET UNLOGGED;
ALTER TABLE profession SET UNLOGGED;
ALTER TABLE media SET UNLOGGED;
ALTER TABLE person SET UNLOGGED;


\copy person FROM 'data/person.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy profession FROM 'data/profession.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy have_profession FROM 'data/have_profession.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy known_for FROM 'data/known_for.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy media FROM 'data/media.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy have_genre FROM 'data/have_genre.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy direct FROM 'data/direct.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy play FROM 'data/play.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy have_episode FROM 'data/have_episode.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');
\copy aka FROM 'data/aka.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER, ENCODING 'UTF-8');

ALTER TABLE aka SET LOGGED;
ALTER TABLE direct SET LOGGED;
ALTER TABLE have_episode SET LOGGED;
ALTER TABLE have_genre SET LOGGED;
ALTER TABLE have_profession SET LOGGED;
ALTER TABLE known_for SET LOGGED;
ALTER TABLE media SET LOGGED;
ALTER TABLE person SET LOGGED;
ALTER TABLE play SET LOGGED;
ALTER TABLE profession SET LOGGED;