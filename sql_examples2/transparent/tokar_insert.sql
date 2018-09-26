START TRANSACTION ;

create or replace function 
transparent.new_tokar_inserted () returns trigger
   language plpgsql 
   security definer
   called on null input
   volatile
   as
$body$
BEGIN
   insert into transparent.worker (
         iid, familia, tnumber, trating
   ) values (
         NEW.iid, NEW.familia, NEW.tnumber, NEW.trating
   ) ;
   insert into transparent.tokar_data (
         iid, category
   ) values (
         NEW.iid, NEW.category
   ) ;
   return NEW ; -- если NEW то результ множество попадает и вставляется в таблицу если NULL то нет
END ;
$body$ ;


create trigger new_tokar_trigger
   instead of insert
   on transparent.tokar 
   for each row
   execute procedure transparent.new_tokar_inserted() ;

COMMIT TRANSACTION ;
