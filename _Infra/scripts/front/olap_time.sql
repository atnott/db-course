do $$
begin
    begin
        drop table if exists dim_time;
        drop sequence if exists seq_dim_time;

        create sequence seq_dim_time;
        create table dim_time (
            id bigint primary key default nextval('seq_dim_time'),
            month_start date not null,
            month_end date not null,
            month_name text not null,
            year integer not null,
            quarter_number integer not null,
            quarter_name text not null,
            date_add timestamp not null default now()
        );

        comment on table dim_time is 'Время';
        comment on column dim_time.id is 'Уникальный код';
        comment on column dim_time.month_start is 'Дата начала месяца';
        comment on column dim_time.month_end is 'Дата окончания месяца';
        comment on column dim_time.month_name is 'Название месяца';
        comment on column dim_time.year is 'Год';
        comment on column dim_time.quarter_number is 'Номер квартала';
        comment on column dim_time.quarter_name is 'Название квартала';
        comment on column dim_time.date_add is 'Дата добавления';

        alter table dim_time add constraint uq_dim_time_month_start unique (month_start);

    exception when others then
        raise notice 'Ошибка при создании таблицы времени: %', sqlerrm;
        raise;
    end;

    begin
        insert into dim_time (month_start, month_end, month_name, year, quarter_number, quarter_name)
        select
            cast(m as date),
            cast(m + interval '1 month' - interval '1 day' as date),
            (array['Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
                   'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'])
                [cast(extract(month from m) as integer)],
            cast(extract(year from m) as integer),
            cast(extract(quarter from m) as integer),
            cast(extract(quarter from m) as text) || ' квартал'
        from generate_series(date '2014-01-01', date '2023-12-01', interval '1 month') as m;

    exception when others then
        raise notice 'Ошибка при заполнении таблицы времени: %', sqlerrm;
        raise;
    end;
end $$;
