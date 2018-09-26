START TRANSACTION ;

alter table transparent.tokar_data
   add constraint tokar_data_worker_fkey
         foreign key (iid)
         references transparent.worker(iid)
         on delete cascade
         on update cascade
         not deferrable ;

---------------------------------------------------------

create or replace function
transparent.tokar_update() returns trigger
   language plpgsql
   security definer
   called on null input 
   volatile
   as
   
$body$
BEGIN
   update transparent.worker
      set iid     = NEW.iid,
          familia = NEW.familia,
          tnumber = NEW.tnumber,
          trating = NEW.trating
      where transparent.worker.iid = OLD.iid ;
   update transparent.tokar_data
      set category = NEW.category
      where transparent.tokar_data.iid = NEW.iid ;
   return NEW ;
END ;
$body$ ;
/*
create trigger tokar_update_trigger
   instead of update
   on transparent.tokar
   for each row
   execute procedure transparent.tokar_update() ;
*/
   
---------------------------------------------------------

create or replace function
transparent.tokar_delete() returns trigger
   language plpgsql
   security definer
   called on null input 
   volatile
   as
$$
BEGIN
   delete from transparent.worker
      where iid = OLD.iid ;
   return OLD ;
END ;
$$ ;

/*
create trigger tokar_delete_trigger
   instead of delete 
   on transparent.tokar
   for each row
   execute procedure transparent.tokar_delete() ;
*/
COMMIT TRANSACTION ;
