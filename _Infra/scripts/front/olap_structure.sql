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

    begin -- виды оплаты
        drop table if exists dim_payment_types;
        drop sequence if exists seq_dim_payment_types;

        create sequence seq_dim_payment_types;
        create table dim_payment_types (
            id bigint primary key default nextval('seq_dim_payment_types'),
            external_id bigint not null,
            name text not null,
            date_add timestamp not null default now()
        );

        comment on table dim_payment_types is 'Виды оплаты';
        comment on column dim_payment_types.id is 'Уникальный код';
        comment on column dim_payment_types.external_id is 'Внешний код в исходной таблице';
        comment on column dim_payment_types.name is 'Наименование';
        comment on column dim_payment_types.date_add is 'Дата добавления';

        alter table dim_payment_types add constraint uq_dim_payment_types_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании видов оплаты: %', sqlerrm;
        raise;
    end;

    begin -- склады
        drop table if exists dim_storages;
        drop sequence if exists seq_dim_storages;

        create sequence seq_dim_storages;
        create table dim_storages (
            id bigint primary key default nextval('seq_dim_storages'),
            external_id bigint not null,
            name text not null,
            date_add timestamp not null default now()
        );

        comment on table dim_storages is 'Склады';
        comment on column dim_storages.id is 'Уникальный код';
        comment on column dim_storages.external_id is 'Внешний код в исходной таблице';
        comment on column dim_storages.name is 'Наименование';
        comment on column dim_storages.date_add is 'Дата добавления';

        alter table dim_storages add constraint uq_dim_storages_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании складов: %', sqlerrm;
        raise;
    end;

    begin -- причины списания
        drop table if exists dim_reasons;
        drop sequence if exists seq_dim_reasons;

        create sequence seq_dim_reasons;
        create table dim_reasons (
            id bigint primary key default nextval('seq_dim_reasons'),
            external_id bigint not null,
            name text not null,
            parent_id bigint,
            date_add timestamp not null default now()
        );

        comment on table dim_reasons is 'Причины списания';
        comment on column dim_reasons.id is 'Уникальный код';
        comment on column dim_reasons.external_id is 'Внешний код в исходной таблице';
        comment on column dim_reasons.name is 'Наименование';
        comment on column dim_reasons.parent_id is 'Код родительской причины в исходной таблице';
        comment on column dim_reasons.date_add is 'Дата добавления';

        alter table dim_reasons add constraint uq_dim_reasons_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании причин списания: %', sqlerrm;
        raise;
    end;

    begin -- сотрудники
        drop table if exists dim_employees;
        drop sequence if exists seq_dim_employees;

        create sequence seq_dim_employees;
        create table dim_employees (
            id bigint primary key default nextval('seq_dim_employees'),
            external_id bigint not null,
            name text not null,
            date_add timestamp not null default now()
        );

        comment on table dim_employees is 'Сотрудники';
        comment on column dim_employees.id is 'Уникальный код';
        comment on column dim_employees.external_id is 'Внешний код в исходной таблице';
        comment on column dim_employees.name is 'ФИО сотрудника';
        comment on column dim_employees.date_add is 'Дата добавления';

        alter table dim_employees add constraint uq_dim_employees_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании сотрудников: %', sqlerrm;
        raise;
    end;

    begin -- категории товаров
        drop table if exists dim_categories;
        drop sequence if exists seq_dim_categories;

        create sequence seq_dim_categories;
        create table dim_categories (
            id bigint primary key default nextval('seq_dim_categories'),
            external_id bigint not null,
            name text not null,
            parent_id bigint,
            date_add timestamp not null default now()
        );

        comment on table dim_categories is 'Категории товаров';
        comment on column dim_categories.id is 'Уникальный код';
        comment on column dim_categories.external_id is 'Внешний код в исходной таблице';
        comment on column dim_categories.name is 'Наименование';
        comment on column dim_categories.parent_id is 'Код родительской категории в исходной таблице';
        comment on column dim_categories.date_add is 'Дата добавления';

        alter table dim_categories add constraint uq_dim_categories_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании категорий: %', sqlerrm;
        raise;
    end;

    begin -- товары
        drop table if exists dim_products;
        drop sequence if exists seq_dim_products;

        create sequence seq_dim_products;
        create table dim_products (
            id bigint primary key default nextval('seq_dim_products'),
            external_id bigint not null,
            code text,
            name text not null,
            date_add timestamp not null default now()
        );

        comment on table dim_products is 'Товары';
        comment on column dim_products.id is 'Уникальный код';
        comment on column dim_products.external_id is 'Внешний код в исходной таблице';
        comment on column dim_products.code is 'Код товара для журнала';
        comment on column dim_products.name is 'Наименование';
        comment on column dim_products.date_add is 'Дата добавления';

        alter table dim_products add constraint uq_dim_products_external_id unique (external_id);

    exception when others then
        raise notice 'Ошибка при создании товаров: %', sqlerrm;
        raise;
    end;

end $$;
