alter table osm.nodes
   add column if not exists osmid bigint,
   add column if not exists pos Geography(POINT,4326),
   add column if not exists tags hstore ;
