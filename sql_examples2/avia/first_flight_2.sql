START TRANSACTION ;

-- set local search_path = "$user", bookings, public ;

create or replace function 
next_flights (dep_city text, 
              larr_city text,
              quantity integer default 1,
              just_now timestamp default bookings.now() )
   returns setof bookings.flights
   language plpgsql
   security definer
   called on null input /*если функция возвр резуль множество то пишем так*/
   stable
   set search_path = bookings, public
   as
$body$
BEGIN

   return query
   select f.*
      from airports as a
      inner join flights as f
         on f.departure_airport = a.airport_code
      inner join airports as b
         on f.arrival_airport = b.airport_code
      where (a.city = dep_city)
            and (b.city = arr_city)
            and (scheduled_departure > just_now)
      order by f.scheduled_departure
      limit quantity ;
   
END ;
$body$ ;

COMMIT TRANSACTION ;
