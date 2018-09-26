select 
   n.iid, 
   (xpath('/tag/@k', tag))[1] as k,
   (xpath('/tag/@v', tag))[1] as v
   from osm.nodes as n, 
        unnest(xpath('/node/tag', n.data)) as tag ;
