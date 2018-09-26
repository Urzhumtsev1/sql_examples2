START TRANSACTION ;
/*
create table osm.nodes(
   iid bigserial not null primary key,
   iid_rawdata bigint not null references osm.raw_data (iid),
   data xml 
) ;

create table osm.ways(
   iid bigserial not null primary key,
   iid_rawdata bigint not null references osm.raw_data (iid),
   data xml 
) ;

create table osm.relations(
   iid bigserial not null primary key,
   iid_rawdata bigint not null references osm.raw_data (iid),
   data xml 
) ;
*/
create or replace function 
osm.read_raw_data () returns int
   language plpgsql
   security definer
   called on null input
   volatile
   set search_path = osm, public
   as
$body$
DECLARE 
   quantity int ;
   x int ;
BEGIN 
   
   create temporary table raw (
      iid bigint,
      data xml
    ) on commit drop ;
    
   insert into raw( iid, data)
      select iid, data
         from raw_data 
         where data is not null ;
   
   insert into nodes ( iid_rawdata, data)
   select r.iid, n 
      from raw as r,
            unnest(xpath('//node', r.data)) as n ;
   
   get diagnostics x = ROW_COUNT ; -- берет значение и 
   quantity := x ;
   
   insert into ways ( iid_rawdata, data)
   select r.iid, n
      from raw as r,
            unnest(xpath('//way', r.data)) as n ;
   
   get diagnostics x = ROW_COUNT ; -- берет значение и 
   quantity := quantity + x ;
   
   insert into relations ( iid_rawdata, data)
   select r.iid, n
      from raw as r,
            unnest(xpath('//relation', r.data)) as n ; -- unnest преобразование массива в результир множество 
   
   get diagnostics x = ROW_COUNT ; -- считает кол-во всталенных строк
   quantity := quantity + x ;
   
   update raw_data 
      set data = NULL
      where iid in ( select iid from raw ) ;

   drop table raw ;
   
   return quantity ;
END ;
$body$ ;

COMMIT TRANSACTION ;
