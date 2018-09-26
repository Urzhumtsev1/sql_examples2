START TRANSACTION ;

create temporary table cities (
   dep text,
   arr text
) on commit drop ;

insert into cities (dep, arr)
   values ('Москва','Санкт-Петербург'),
          ('Москва','Казань'),
          ('Москва','Челябинск') ;

select
      c.dep,
      c.arr,
      f.flight_no,
      f.scheduled_departure,
      f.ordinality
   from cities as c,
        next_flights(c.dep, c.arr, 4) with ordinality as f 
   -- order by f.scheduled_arrival
   ;

COMMIT TRANSACTION ;
