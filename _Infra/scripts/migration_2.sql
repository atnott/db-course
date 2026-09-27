drop table if exists base_units;
drop table if exists units;
drop table if exists parameter_types;

create table base_units(
id int primary key,
name varchar(50) not null
);

comment on table base_units is 'Таблица базовых единиц измерения';
comment on column base_units.id is 'Уникальный код базовой единицы измерения';
comment on column base_units.name is 'Наименование единицы измерения';

create table units(
id int primary key,
name varchar(50) not null,
base_unit_id int references base_units(id)
);

comment on table units is 'Таблица единиц измерения';
comment on column units.id is 'Уникальный код единицы измерения';
comment on column units.name is 'Тип единицы измерения';
comment on column units.base_unit_id is 'Rод единицы измерения';

create table parameter_types(
id int primary key,
name varchar(50) not null
);

comment on table parameter_types is 'Таблица параметров единицы измерения';
comment on column parameter_types.id is 'Уникальный код параметра';
comment on column parameter_types.name is 'Наименование параметра';