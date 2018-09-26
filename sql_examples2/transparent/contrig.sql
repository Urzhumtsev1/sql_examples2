/*
create table example01 (
   iid serial not null primary key,
   x int not null 
) ;
*/
create or replace function 
check_example01() returns trigger
   security definer
   called on null input
   stable
   language plpgsql
   as
$$
DECLARE 
   y int ;
BEGIN
   select coalesce(sum(x), 0)
      into strict y
      from example01 ;
   if TG_OP in ( 'INSERT', 'UPDATE') then
      y := y + NEW.x ;
   end if ;
   if TG_OP in ( 'INSERT', 'DELETE') then
      y := y - OLD.x ;
   end if ;
   if y % 2 != 0 then
      raise 'sum in column x must be even (got %)', y using errcode = 'check_violation' ;
   end if ;
   return NULL ;
END ;
$$ ;

/*
create constraint trigger example01_positive_trigger -- триггер констрэинт может быть только after
   after insert or update or delete
   on example01
   deferrable initially immediate -- данная проверка может быть отложена до конца транзакции (так делаем для constraint trigger)
   for each row
   execute procedure check_example01() ;
*/
