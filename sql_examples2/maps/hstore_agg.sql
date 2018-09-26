START TRANSACTION ;

create or replace function
hstore_agg_transition( current_state hstore, current_value hstore )
   returns hstore
   language plpgsql
   immutable
   security invoker
   called on null input
   as
   
$body$
BEGIN
   if current_state is NULL then
      return current_value ;
   elsif current_value is NULL then 
      return current_state ;
   end if ;
   return current_state || current_value ;
   
END ;
$body$ ;

create or replace function
hstore_agg_final ( current_state hstore )
   returns hstore
   language plpgsql
   immutable
   security invoker
   returns null on null input
   as
$body$
BEGIN
   if cardinality(akeys(current_state)) <= 0 then -- cardinality возвращает все элементы в массиве
      return NULL ;
   end if ;
   return current_state ;
END ;
$body$ ;


create aggregate hstore_agg( hstore ) (
   sfunc     = hstore_agg_transition,
   stype     = hstore,
   finalfunc = hstore_agg_final
) ;

COMMIT TRANSACTION ;
