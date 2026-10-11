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


end $$;