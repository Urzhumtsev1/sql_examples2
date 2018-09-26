START TRANSACTION ;

create or replace function 
osm.after_new_nodes_inserted() returns trigger
   language plpgsql
   security definer
   volatile 
   called on null input
   as
$body$
BEGIN
   
   with 
   one as (
      select 
            nn.iid                      as iid,
            osm_id::text::bigint        as osmid,
            lon::text::double precision as lon,
            lat::text::double precision as lat,
            keys::text[]                as keys, 
            vals::text[]                as vals
         from new_nodes as nn,
              unnest(xpath('/node/@id' ,nn.data))     as osm_id,
              unnest(xpath('/node/@lon',nn.data))     as lon,
              unnest(xpath('/node/@lat',nn.data))     as lat,
              xpath('/node/tag/@k',nn.data)           as keys,
              xpath('/node/tag/@v',nn.data)           as vals
         where data is not null
   ),
   two as (
      select
            iid,
            osmid,
            Geography(ST_SetSRID(ST_MakePoint(lon, lat), 4326)) as pos,
            hstore(keys, vals) as tags
         from one 
   )
   update osm.nodes
      set osmid = two.osmid,
         pos    = two.pos,
         tags   = two.tags,
         data   = null
      from two 
      where osm.nodes.iid = two.iid ;
      
   return null ;
   
END ;
$body$ ;
/*
create trigger on_new_nodes_inserted
   after insert on osm.nodes 
   referencing new table as new_nodes 
   for each statement 
   execute procedure osm.after_new_nodes_inserted() ;
*/
COMMIT TRANSACTION ;
