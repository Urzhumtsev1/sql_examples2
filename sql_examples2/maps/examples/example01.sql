START TRANSACTION ;
set local search_path = example01, public ;

create schema if not exists example01 ;

create table tbl01 (
   iid serial not null primary key,
   aname text not null unique,
   acomment text
);

create table tbl02 (
   series int 
) 
inherits (tbl01) ;

COMMIT TRANSACTION ;
