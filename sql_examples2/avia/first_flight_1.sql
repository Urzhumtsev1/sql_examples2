START TRANSACTION ;

-- set local search_path = "$user", bookings, public ;

create or replace function 
one_first_flight (dep_city text, 
                  arr_city text, 
                  just_now timestamp default bookings.now() )
   returns integer
   language plpgsql
   security definer
   returns null on null input
   stable
   as
$body$
DECLARE
   r_flight_id integer ;
BEGIN

   select 
         f.flight_id
      into strict r_flight_id /* strict - требуем чтобы была строка и она была только одна*/
      from airports as a
      inner join flights as f
         on f.departure_airport = a.airport_code
      inner join airports as b
         on f.arrival_airport = b.airport_code
      where (a.city = dep_city)
            and (b.city = arr_city)
            and (scheduled_departure > just_now)
      order by f.scheduled_departure
      limit 1 ;
   
   return r_flight_id ;

EXCEPTION 
   when no_data_found then
      return NULL ;
   
END ;
   
$body$
set search_path = bookings, public ;

COMMIT TRANSACTION ;
