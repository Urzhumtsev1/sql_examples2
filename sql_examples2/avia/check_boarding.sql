START TRANSACTION ;
set local search_path = "$user", bookings, public ;

with tick as (
      select ticket_no
         from tickets
         limit 1
),         
tn as (
select 
      tck.ticket_no,
      flt.flight_no
   from next_flights('Москва', 'Санкт-Петербург', 10) as flt,
         tick as tck
   limit 10000
)
select 
      tn.ticket_no, tn.flight_no, stn
   from tn,
   can_take_pass (tn.flight_no, tn.ticket_no, 'Economy', 0) as stn
   where stn is not NULL
   ;


COMMIT TRANSACTION ;
