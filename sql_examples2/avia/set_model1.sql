START TRANSACTION ;
/*
create type two_numbers as (
   num bigint,
   frac double precision
);
*/
create or replace function
simple_pairs()
   returns setof two_numbers
   called on null input
   security invoker
   immutable
   language plpgsql
   as
$body$
BEGIN
   return next (1::bigint, 10::double precision) ; /* следующая запсь результ множества*/
   return next (2::bigint, 20::double precision) ;
   return next (3::bigint, 30::double precision) ;
   return next (4::bigint, NULL::double precision) ;
END ;
$body$ ;

create or replace function
fibonacci(quantity integer)
   returns setof two_numbersl
   called on null input
   security invoker
   immutable
   language plpgsql
   as
$body$
DECLARE 
   i integer ;
   a bigint ;
   b bigint ;
   c bigint ;
BEGIN
   a := 1 ;
   b := 1 ;
   for i in 1 .. quantity loop
      return next (a, (a::double precision) / (b::double precision)) ;
      c := a ;
      a := b ;
      b := a + c ;
   end loop ;
END ;
$body$ ;

COMMIT TRANSACTION ;
