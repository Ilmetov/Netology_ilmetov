CREATE TABLE public.links_parted (
    movieId bigint,
    imdbid varchar (20),
    tmdbid varchar (20)
);


CREATE TABLE links_parted_1 (
    CHECK ( movieId % 2 = 1 )
) INHERITS (links_parted);

CREATE TABLE links_parted_2 (
    CHECK ( movieId % 2 = 0 )
) INHERITS (links_parted);

CREATE RULE links_insert_1 AS ON INSERT TO links_parted
WHERE ( movieId % 2 = 1 )
DO INSTEAD INSERT INTO links_parted_1 VALUES ( NEW.* );


CREATE RULE links_insert_2 AS ON INSERT TO links_parted
WHERE ( movieId % 2 = 0 )
DO INSTEAD INSERT INTO links_parted_2 VALUES ( NEW.* );

INSERT INTO links_parted (
    SELECT *
    FROM links
    WHERE movieId between 2 and 20
);




select *  from public.links_parted;
select * from public.links_parted_1;
select * from public.links_parted_2;
/*
delete from public.links_parted;
delete from public.links_parted_1;
delete from public.links_parted_2; */