select 
   n.iid, 
   hstore_agg (hstore( ((xpath('/tag/@k', tag))[1])::text, -- агрегатная функция работает как конечный автоматl
                ((xpath('/tag/@v', tag))[1])::text ) ) as tags
   from osm.nodes as n, 
        unnest(xpath('/node/tag', n.data)) as tag 
   group by n.iid ;
