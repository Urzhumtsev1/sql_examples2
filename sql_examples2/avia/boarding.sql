START TRANSACTION ;

create type flight_seat as (
   flight_id integer,
   seat_no varchar(4)
) ;

create or replace function 
can_take_pass(
              aflight_no char (6),
              aticket_no char (13),
              afare      varchar(10),
              aprice     numeric(10,2) )
   returns flight_seat
   language plpgsql
   security definer
   returns null on null input /* если какой то параметр NULL то и результат тоже будет NULL*/
   set search_path = "$user", bookings, public
   volatile
   as
   
$body$
declare
   R flight_seat ;
   -- aflight_id integer ;
   aaircraft_code char(3) ;
   atime_lim timestamp;
   -- aseat_no varchar (4) ;
   abook_ref char(6) ;
   aspent numeric (10,2) ;

begin

   atime_lim := bookings.now() + '10 hours'::interval ;
   
   perform pg_notify('debug', aflight_no||'-'||aticket_no ) ;
   
   select flt.flight_id, aircraft_code
      into strict R.flight_id, aaircraft_code
      from flights as flt
      where  (flt.flight_no = aflight_no)
        and (flt.actual_departure is null) 
        and (flt.scheduled_departure < atime_lim )
      order by flt.scheduled_departure asc
      limit 1 ;

   perform pg_notify('debug', 'CODE'||aaircraft_code) ;
   -- return aflight_id::text::char(4) ;
   
   begin
      select seat_no
         into strict R.seat_no
         from boarding_passes
         where (flight_id = R.flight_id)
           and (ticket_no = aticket_no) ;
           
      return R ;
      
   exception
       when no_data_found then null ;
   end;
   
   select 
         s.seat_no
      into strict R.seat_no
      from seats as s
      where  ( s.aircraft_code = aaircraft_code )
         and ( s.seat_no not in ( select bp.seat_no 
                                     from boarding_passes as bp 
                                     where bp.flight_id = R.flight_id ) )
         and ( s.fare_conditions = afare )
         limit 1 ;
         
    perform pg_notify('debug', 'SEAT'||R.seat_no) ;
         
   perform *
      from ticket_flights as tft
      where  tft.ticket_no = aticket_no
         and tft.flight_id = R.flight_id ;
   if found then
      return R ;
   end if ;
   
   NOTIFY debug, 'Ticket is not ready' ;
   
   select tck.book_ref
      into strict abook_ref
      from tickets as tck
      where tck.ticket_no = aticket_no ;
      
   NOTIFY debug, 'Book: ' ;   
      
   select 
         sum (tfl.amount)
      into strict aspent
      from tickets as tck
      inner join ticket_flights as tfl 
         on tck.ticket_no = tfl.ticket_no
      where tck.book_ref = abook_ref ;
     
   NOTIFY debug, 'SPENT: ' ;  
     
   perform *
      from bookings
      where total_amount >= aprice + coalesce(aspent, 0) ;
      
   if not found then
      return NULL ; -- ??????????
   end if ;
   
   NOTIFY debug, 'SEAT READY ' ;
   
   return R ;

EXCEPTION

   when no_data_found then 
      NOTIFY debug, 'No data found' ;
      return NULL ; -- ????????????
   
   
end ;
$body$ ;

COMMIT TRANSACTION ;
