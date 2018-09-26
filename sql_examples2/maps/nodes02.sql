create or replace function
osm.analyze_nodes () returns bigint
   language plpgsql
   called on null input
   volatile
   security definer
   set search_path = osm, public
   as
$body$
DECLARE 
BEGIN

   create temporary table new_nodes (
      like osm.nodes
   ) on commit drop ;
   
   insert into new_nodes
      select * from nodes ;
   
   update new_nodes
      set osmid = ((xpath('/node/@id',data))[1])::text::bigint,
          pos =   Geography(
                     ST_SetSRID(
                        ST_MakePoint( ((xpath('/node/@lon',data))[1])::text::double precision,
                                      ((xpath('/node/@lat',data))[1])::text::double precision  ),
                        4326 ) ) ;
   with ntags as (
      select 
             n.iid, 
             hstore_agg (hstore( ((xpath('/tag/@k', tag))[1])::text, -- агр функция работает как конечный автомат
                                 ((xpath('/tag/@v', tag))[1])::text ) ) as tags
      from new_nodes as n, 
           unnest(xpath('/node/tag', n.data)) as tag 
      group by n.iid 
   )
   update new_nodes
      set tags = n.tags
      from ntags as n
      where new_nodes.iid = n.iid ;
      
   update osm.nodes 
      set osmid = n.osmid,
          pos   = n.pos,
          tags  = n.tags,
          data  = null 
      from new_nodes as n 
      where osm.nodes.iid = n.iid ;
   
   drop table new_nodes ;
   
   return 0 ;
END ;
$body$ ;
