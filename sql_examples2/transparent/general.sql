START TRANSACTION ;
set local search_path = transparent, public ;

create schema if not exists transparent ;

create domain rating as integer
   check (VALUE >= 1 and VALUE <= 6) ;

create sequence worker_seq ;  
   
create table worker (
   iid integer not null primary key default nextval('transparent.worker_seq'),
   familia text not null,
   tnumber text unique,
   trating rating not null default 1
) ;

alter sequence worker_seq owned by worker.iid ; -- последовательность привязанная к колонк, это и наз-ся сериал

-- создать бд с 2 поялми после этого пг_дамп ее и посмотеть что там написано (не будет сериал)

create table tokar_data (
   iid integer not null primary key,д
   category int
) ;

create table tokar (
   iid integer not null default nextval('transparent.worker_seq'),
   familia text not null,
   tnumber text,
   trating rating not null default 1,
   category int 
) ;

COMMIT TRANSACTION ;
