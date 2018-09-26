alter table osm.ways
   add column if not exists osmid bigint,
   add column if not exists apath Geography(LINESTRING, 4326),
   add column if not exists tags hstore ;
   
