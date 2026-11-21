do $$
begin

    begin -- единицы измереия
        drop table if exists dim_ranges;
        drop sequence if exists seq_dim_ranges;

        create sequence seq_dim_ranges;
        create table dim_ranges (
            id bigint primary key default nextval('seq_dim_ranges'),
            external_id bigint not null,
            name text not null,
            factor float,
            base_external_id bigint,
            base_name text,
            date_add timestamp not null default now()
        );

        comment on table dim_ranges is 'Единицы измерения';
        comment on column dim_ranges.id is 'Уникальный код';
        comment on column dim_ranges.external_id is 'Внешний код в исходной таблице';
        comment on column dim_ranges.name is 'Наименование';
        comment on column dim_ranges.factor is 'Коэффициент перевода в базовую единицу';
        comment on column dim_ranges.base_external_id is 'Код базовой единицы в исходной таблице';
        comment on column dim_ranges.base_name is 'Наименование базовой единицы';
        comment on column dim_ranges.date_add is 'Дата добавления';

        alter table dim_ranges add constraint uq_dim_ranges_external_id unique (external_id);

    exception when others then
		raise notice 'Ошибка при создании единиц измерения: %', sqlerrm;
		raise;
    end;

    begin -- поставщики
        drop table if exists dim_vendors;
        drop sequence if exists seq_dim_vendors;

        create sequence seq_dim_vendors;
        create table dim_vendors (
            id bigint primary key default nextval('seq_dim_vendors'),
            external_id bigint not null,
            name text not null,
            group_external_id bigint,
            group_name text,
            date_add timestamp not null default now()
        );

        comment on table dim_vendors is 'Поставщики';
        comment on column dim_vendors.id is 'Уникальный код';
        comment on column dim_vendors.external_id is 'Внешний код в исходной таблице';
        comment on column dim_vendors.name is 'Краткое название поставщика';
        comment on column dim_vendors.group_external_id is 'Код группы поставщиков в исходной таблице';
        comment on column dim_vendors.group_name is 'Наименование группы поставщиков';
        comment on column dim_vendors.date_add is 'Дата добавления';

        alter table dim_vendors add constraint uq_dim_vendors_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании поставщиков: %', sqlerrm;
        raise;
    end;

end $$;