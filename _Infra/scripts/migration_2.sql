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

insert into base_units(id, name) values
(1, 'Длина'),
(2, 'Температура'),
(3, 'Давление'),
(4, 'Угол'),
(5, 'Скорость');

insert into units(id, name, base_unit_id) values
(1, 'метр', 1),
(2, 'градус Цельсия', 2),
(3, 'мм рт. ст.', 3),
(4, 'д.у.', 4),
(5, 'м/с', 5);

insert into parameter_types(id, name) values
(1, 'Метеорологический'),
(2, 'Геодезический'),
(3, 'Баллистический');

alter table parameters
add column unit_id int references units(id),
add column parameter_type_id int references parameter_types(id);

comment on column parameters.unit_id is 'Код единицы измерения';
comment on column parameters.parameter_id is 'Код типа параметра';
