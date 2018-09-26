START TRANSACTION ;
--set local search_path = transparent, public ;

create rule "_RETURN" as -- в постгрес таблица с правилами = представление
   on select 
   to transparent.tokar
   do instead 
   select 
         w.iid      as iid,
         w.familia  as familia,
         w.tnumber  as tnumber,
         w.trating  as trating,
         t.category as category
      from transparent.worker as w
      inner join transparent.tokar_data as t
         on t.iid = w.iid ;
COMMIT TRANSACTION ;
