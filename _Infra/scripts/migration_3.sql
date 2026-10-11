do $$
begin

	begin
		drop table if exists pack_parameters cascade;
		drop table if exists packs cascade;
		drop table if exists parameters cascade;
		drop table if exists users cascade;
		drop table if exists equipment_types cascade;
		drop table if exists ranks cascade;
		drop table if exists units cascade;
		drop table if exists base_units cascade;
		drop table if exists parameter_types cascade;
		drop table if exists temperature_corrections cascade;
	
		create sequence base_units_id_seq;
		create table base_units (
		    id int primary key default nextval('base_units_id_seq'),
		    name varchar(50) not null
		);
		alter sequence base_units_id_seq owned by base_units.id;
	
		create sequence units_id_seq;
		create table units (
		    id int primary key default nextval('units_id_seq'),
		    name varchar(50) not null,
		    base_unit_id int
		);
		alter sequence units_id_seq owned by units.id;
	
		create sequence parameter_types_id_seq;
		create table parameter_types (
		    id int primary key default nextval('parameter_types_id_seq'),
		    name varchar(50) not null
		);
		alter sequence parameter_types_id_seq owned by parameter_types.id;
	
		create sequence ranks_id_seq;
		create table ranks (
		    id int primary key default nextval('ranks_id_seq'),
		    title varchar(150) not null
		);
		alter sequence ranks_id_seq owned by ranks.id;
	
		create sequence equipment_types_id_seq;
		create table equipment_types (
		    id int primary key default nextval('equipment_types_id_seq'),
		    name varchar(150) not null
		);
		alter sequence equipment_types_id_seq owned by equipment_types.id;
	
		create sequence parameters_id_seq;
		create table parameters (
		    id int primary key default nextval('parameters_id_seq'),
		    name varchar(150) not null unique,
		    unit_id int,
		    parameter_type_id int
		);
		alter sequence parameters_id_seq owned by parameters.id;
	
		create sequence users_id_seq;
		create table users (
		    id int primary key default nextval('users_id_seq'),
		    name varchar(150) not null,
		    rank_id int,
		    equipment_type_id int
		);
		alter sequence users_id_seq owned by users.id;
	
		create sequence packs_id_seq;
		create table packs (
		    id int primary key default nextval('packs_id_seq'),
		    name varchar(150) not null,
		    created_at date,
		    user_id int
		);
		alter sequence packs_id_seq owned by packs.id;
	
		create sequence pack_parameters_id_seq;
		create table pack_parameters (
		    id int primary key default nextval('pack_parameters_id_seq'),
		    pack_id int,
		    parameter_id int,
		    value varchar(50) not null
		);
		alter sequence pack_parameters_id_seq owned by pack_parameters.id;
	
		create sequence temperature_corrections_id_seq;
		create table temperature_corrections (
		    id int primary key default nextval('temperature_corrections_id_seq'),
		    temp_range_desc varchar(50) not null,
		    delta_tv numeric(4,2) not null
		);
		alter sequence temperature_corrections_id_seq owned by temperature_corrections.id;
	end;

	begin
		insert into base_units(id, name) values
		(1, 'Длина'), (2, 'Температура'), (3, 'Давление'), (4, 'Угол'), (5, 'Скорость');

		insert into units(id, name, base_unit_id) values
		(1, 'метр', 1), (2, 'градус Цельсия', 2), (3, 'мм рт. ст.', 3), (4, 'д.у.', 4), (5, 'м/с', 5);

		insert into parameter_types(id, name) values
		(1, 'Метеорологический'), (2, 'Геодезический'), (3, 'Баллистический');

		insert into ranks (id, title) values 
		(1, 'Оператор метеопоста'), (2, 'Вычислитель артиллерийского дивизиона');

		insert into equipment_types (id, name) values 
		(1, 'Десантный метеокомплект (ДМК)'), (2, 'Ветровое ружье');

		insert into parameters (id, name, unit_id, parameter_type_id) values 
		(1, 'Высота метеопоста', 1, 2),
		(2, 'Температура воздуха', 2, 1),
		(3, 'Давление атмосферы', 3, 1),
		(4, 'Направление ветра', 4, 3),
		(5, 'Скорость ветра', 5, 1),
		(6, 'Дальность сноса пуль', 1, 3);

		insert into users (id, name, rank_id, equipment_type_id) values 
		(1, 'Смирнов Алексей Игоревич', 1, 1),
		(2, 'Ковалев Дмитрий Сергеевич', 2, 2);

		insert into packs (id, name, created_at, user_id) values 
		(1, '24093', '2026-09-20', 1),
		(2, '24094', '2026-09-21', 2),
		(3, '24095', '2026-09-22', 1),
		(4, '24096', '2026-09-23', 2),
		(5, '24097', '2026-09-24', 1),
		(6, '24098', '2026-09-25', 2),
		(7, '24099', '2026-09-26', 1),
		(8, '24100', '2026-09-27', 1),
		(9, '24101', '2026-09-28', 1),
		(10, '24102', '2026-09-29', 1);

		insert into pack_parameters (id, pack_id, parameter_id, value) values 
		(1, 1, 1, '100'), (2, 1, 2, '15'), (3, 1, 3, '750'), (4, 1, 4, '00'), (5, 1, 5, '5'), (6, 1, 6, '0'),
		(7, 2, 1, '120'), (8, 2, 2, '18'), (9, 2, 3, '745'), (10, 2, 4, '45'), (11, 2, 5, '7'), (12, 2, 6, '2'),
		(13, 3, 1, '95'), (14, 3, 2, '-300'), (15, 3, 3, '755'), (16, 3, 4, '30'), (17, 3, 5, '4'), (18, 3, 6, '1'),
		(19, 4, 1, '110'), (20, 4, 2, '16'), (21, 4, 3, '748'), (22, 4, 4, '60'), (23, 4, 5, '6'), (24, 4, 6, '3'),
		(25, 5, 1, '105'), (26, 5, 2, '17'), (27, 5, 3, '752'),
		(31, 6, 1, '115'), (32, 6, 2, '19'), (33, 6, 3, '742'), (34, 6, 4, '75'), (35, 6, 5, '8'), (36, 6, 6, '4'),
		(37, 7, 1, '102'), (38, 7, 2, '16'), (39, 7, 3, '751'), (40, 7, 4, '20'), (41, 7, 5, '5'), (42, 7, 6, '1'),
		(43, 8, 1, '118'), (44, 8, 2, '20'), (45, 8, 3, '740'), (46, 8, 4, '80'), (47, 8, 5, '9'), (48, 8, 6, '5'),
		(49, 10, 1, '98'), (50, 10, 2, '15'), (51, 10, 3, '753'), (52, 10, 4, '25'), (53, 10, 5, '6'), (54, 10, 6, '2');

		insert into temperature_corrections (id, temp_range_desc, delta_tv) values
		(1, 'Ниже 0', 0.0),
		(2, '0 - 5', 0.5),
		(3, '10 - 15', 1.0),
		(4, '20', 1.5),
		(5, '25', 2.0),
		(6, '30', 3.5),
		(7, '40', 4.5);

		perform setval('base_units_id_seq', coalesce((select max(id) from base_units), 1));
		perform setval('units_id_seq', coalesce((select max(id) from units), 1));
		perform setval('parameter_types_id_seq', coalesce((select max(id) from parameter_types), 1));
		perform setval('ranks_id_seq', coalesce((select max(id) from ranks), 1));
		perform setval('equipment_types_id_seq', coalesce((select max(id) from equipment_types), 1));
		perform setval('parameters_id_seq', coalesce((select max(id) from parameters), 1));
		perform setval('users_id_seq', coalesce((select max(id) from users), 1));
		perform setval('packs_id_seq', coalesce((select max(id) from packs), 1));
		perform setval('pack_parameters_id_seq', coalesce((select max(id) from pack_parameters), 1));
		perform setval('temperature_corrections_id_seq', coalesce((select max(id) from temperature_corrections), 1));
	end;
	
end $$;