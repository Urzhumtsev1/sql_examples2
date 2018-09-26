with one_way as (select iid, data from osm.ways limit 1)
select 
--      w.iid,
--      nd.ref::text::bigint,
--      nd.ordinal,
--      n.iid,
      ST_AsText(Geography(ST_MakeLine(Geometry(n.pos))))
   from one_way as w, 
        unnest(xpath('/way/nd/@ref', w.data)) with ordinality as nd (ref, ordinal)
   left outer join osm.nodes as n
      on nd.ref::text::bigint = n.osmid ;
