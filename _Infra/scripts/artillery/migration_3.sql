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
		
	exception when others then
		raise notice 'Ошибка в блоке структуры: %', sqlerrm;
		raise;
	end;

	begin
		insert into base_units(name) values
		('Длина'), ('Температура'), ('Давление'), ('Угол'), ('Скорость');

		insert into units(name, base_unit_id) values
		('метр', 1), ('градус Цельсия', 2), ('мм рт. ст.', 3), ('д.у.', 4), ('м/с', 5);

		insert into parameter_types(name) values
		('Метеорологический'), ('Геодезический'), ('Баллистический');

		insert into ranks (title) values 
		('Оператор метеопоста'), ('Вычислитель артиллерийского дивизиона');

		insert into equipment_types (name) values 
		('Десантный метеокомплект (ДМК)'), ('Ветровое ружье');

		insert into parameters (name, unit_id, parameter_type_id) values 
		('Высота метеопоста', 1, 2),
		('Температура воздуха', 2, 1),
		('Давление атмосферы', 3, 1),
		('Направление ветра', 4, 3),
		('Скорость ветра', 5, 1),
		('Дальность сноса пуль', 1, 3);

		insert into users (name, rank_id, equipment_type_id) values 
		('Смирнов Алексей Игоревич', 1, 1),
		('Ковалев Дмитрий Сергеевич', 2, 2);

		insert into packs (name, created_at, user_id) values 
		('24093', '2026-09-20', 1),
		('24094', '2026-09-21', 2),
		('24095', '2026-09-22', 1),
		('24096', '2026-09-23', 2),
		('24097', '2026-09-24', 1),
		('24098', '2026-09-25', 2),
		('24099', '2026-09-26', 1),
		('24100', '2026-09-27', 1),
		('24101', '2026-09-28', 1), 
		('24102', '2026-09-29', 1);

		insert into pack_parameters (pack_id, parameter_id, value) values 
		(1, 1, '100'), (1, 2, '15'), (1, 3, '750'), (1, 4, '00'), (1, 5, '5'), (1, 6, '0'),
		(2, 1, '120'), (2, 2, '18'), (2, 3, '745'), (2, 4, '45'), (2, 5, '7'), (2, 6, '2'),
		(3, 1, '95'), (3, 2, '-300'), (3, 3, '755'), (3, 4, '30'), (3, 5, '4'), (3, 6, '1'),
		(4, 1, '110'), (4, 2, '16'), (4, 3, '748'), (4, 4, '60'), (4, 5, '6'), (4, 6, '3'),
		(5, 1, '105'), (5, 2, '17'), (5, 3, '752'), (5, 4, '15'), (5, 5, '5'), (5, 6, '1'),
		(6, 1, '115'), (6, 2, '19'), (6, 3, '742'), (6, 4, '75'), (6, 5, '8'), (6, 6, '4'),
		(7, 1, '102'), (7, 2, '16'), (7, 3, '751'), (7, 4, '20'), (7, 5, '5'), (7, 6, '1'),
		(8, 1, '118'), (8, 2, '20'), (8, 3, '740'), (8, 4, '80'), (8, 5, '9'), (8, 6, '5'),
		(9, 1, '100'), (9, 2, '16'), (9, 3, '750'), (9, 4, '10'), (9, 5, '4'), (9, 6, '1'),
		(10, 1, '98'), (10, 2, '15'), (10, 3, '753'), (10, 4, '25'), (10, 5, '6'), (10, 6, '2');

		insert into temperature_corrections (temp_range_desc, delta_tv) values
		('Ниже 0', 0.0),
		('0 - 5', 0.5),
		('10 - 15', 1.0),
		('20', 1.5),
		('25', 2.0),
		('30', 3.5),
		('40', 4.5);

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

	exception when others then
		raise notice 'Ошибка в блоке данных: %', sqlerrm;
		raise;
	end;

	begin
		alter table units
			add constraint fk_units_base_units 
			foreign key (base_unit_id) references base_units(id);

		alter table parameters
			add constraint fk_parameters_units foreign key (unit_id) references units(id),
			add constraint fk_parameters_types foreign key (parameter_type_id) references parameter_types(id);

		alter table users
			add constraint fk_users_ranks foreign key (rank_id) references ranks(id),
			add constraint fk_users_equipment foreign key (equipment_type_id) references equipment_types(id);

		alter table packs
			add constraint fk_packs_users foreign key (user_id) references users(id);

		alter table pack_parameters
			add constraint fk_pack_params_packs foreign key (pack_id) references packs(id),
			add constraint fk_pack_params_params foreign key (parameter_id) references parameters(id);
	exception when others then
		raise notice 'Ошибка в внешних ключей: %', sqlerrm;
		raise;
	end;
	
end $$;