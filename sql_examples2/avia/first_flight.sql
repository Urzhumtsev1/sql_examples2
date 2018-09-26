START TRANSACTION ;

set local search_path = "$user", bookings, public ;

select 
      f.flight_id,
      f.flight_no,
      f.scheduled_departure,
      f.scheduled_arrival,
      f.departure_airport,
      f.arrival_airport,
      f.aircraft_code
   from airports as a
   inner join flights as f
      on f.departure_airport = a.airport_code
   inner join airports as b
      on f.arrival_airport = b.airport_code
      where (a.city = 'Москва')
         and (b.city = 'Санкт-Петербург')
         and (scheduled_departure > bookings.now())
   order by f.scheduled_departure
   limit 1 ;


ROLLBACK TRANSACTION ;
