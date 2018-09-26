#!/usr/bin/env python3
# -*- coding; utf-8 -*-

import psycopg2

data_files = ['map.osm', 'map1.osm', 'map3.osm']
conn = psycopg2.connect(dbname='student',
                        user='student',
                        host='localhost',
                        port=5432,
                        password='1')

cursor = conn.cursor()

cursor.execute('''
    PREPARE load_map(xml) as
    insert into osm.raw_data(data)
       values ($1) ;
''')

for filename in data_files:
    src = open(filename, 'rt', encoding='utf-8')
    data = src.read()
    src.close()
    cursor.execute('EXECUTE load_map(%s);', (data,))

conn.commit()
conn.close()
