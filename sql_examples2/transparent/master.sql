create table important_data (
    iid bigserial not null primary key,
    data text,
    importance int
) ;

create publication important_data_anonce
    for table important_data ;
