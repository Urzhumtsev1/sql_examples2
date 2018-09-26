with a as (
   values ( 'a=>1'::hstore ),
          ( 'b=>2'::hstore ),
          ( 'c=>10, d=>20'::hstore)
)
select hstore_agg(column1) from a ;
