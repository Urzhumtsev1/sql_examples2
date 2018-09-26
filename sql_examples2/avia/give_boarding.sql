create or replace function
give_boarding( aflight_no char (6),
               aticket_no char (13),
               afare      varchar(10),
               aprice     numeric(10,2) ) 
   returns varchar (4)
   language plpgsql
   returns null on null input
   security definer
   volatile
   set search_path = "$user", bookings, public
   as
$body$
DECLARE
   seat flight_seat ;
BEGIN 

   seat := can_take_pass(aflight_no, aticket_no, afare, aprice) ;
   if seat is NULL then
      NOTIFY give_debug, 'Seat not found' ;
      return NULL ;
   end if ;
   
   insert into ticket_flights(
      ticket_no, flight_id, fare_conditions, amount
   )   values (
        aticket_no, seat.flight_id, afare, aprice
   )
   on conflict (ticket_no, flight_id) 
   do nothing ;
   
   insert into boarding_passes(
      ticket_no, flight_id, boarding_no, seat_no
   ) values (
      aticket_no, seat.flight_id, -2, seat.seat_no
   ) 
   on conflict (ticket_no, flight_id)
   do update set
            seat_no = seat.seat_no 
        where (boarding_passes.ticket_no = aticket_no)
           and (boarding_passes.flight_id = seat.flight_id) ;
   
   return seat.seat_no ;
           
END ;
$body$ ;

