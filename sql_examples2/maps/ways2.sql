START TRANSACTION ;

create or replace function
osm.new_way() returns trigger
   language plpgsql
   security definer
   called on null input
   volatile
   as
$body$
BEGIN

   with dt as (
      select 
            NEW.iid as iid,
            (xpath('/way/@id', NEW.data))[1]::text::bigint as osmid,
               Geography(
                  ST_MakeLine(
                     Geometry(n.pos)
                     order by nd.ordinal
                  )
            ) as apath,
            hstore( (xpath('/way/tag/@k', NEW.data))::text[],
                    (xpath('/way/tag/@k', NEW.data))::text[] ) as tags
         from unnest(xpath('/way/nd/@ref', NEW.data)) 
                   with ordinality as nd (ref, ordinal)
         left outer join osm.nodes as n
            on nd.ref::text::bigint = n.osmid 
   )
   update osm.ways
      set apath = dt.apath,
          osmid = dt.osmid,
          tags  = dt.tags,
          data  = NULL
      from dt
      where dt.iid = osm.ways.iid ;
   
   return null ;

END ;
$body$ ;

/*
create trigger new_way_trigger
   after insert on osm.ways
   for each row
   execute procedure osm.new_way() ;
*/
COMMIT TRANSACTION ;
