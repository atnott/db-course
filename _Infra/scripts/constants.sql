do $$
begin

	begin
		drop table if exists constants cascade;
		drop table if exists parameter_limits cascade;
		drop table if exists parameter_errors cascade;
		drop sequence if exists seq_constants;
		drop sequence if exists seq_parameter_limits;
		drop sequence if exists seq_parameter_errors;

		create table constants(
	    id integer not null,
	    code varchar(100) not null unique,
	    value numeric not null,
	    description varchar(255) not null
		);
		create sequence seq_constants;
		alter table constants alter column id set default nextval('seq_constants');

		comment on table constants is 'Константы расчета метео';
		comment on column constants.id is 'Уникальный код';
		comment on column constants.code is 'Уникальный код константы';
		comment on column constants.value is 'Значение';
		comment on column constants.description is 'Описание';

		create table if not exists parameter_limits(
	    id integer not null,
	    parameter_id integer not null,
	    min_value numeric,
	    max_value numeric,
	    decimal_places integer
		);
		create sequence seq_parameter_limits;
		alter table parameter_limits alter column id set default nextval('seq_parameter_limits');

		comment on table parameter_limits is 'Допустимые значения входных параметров';
		comment on column parameter_limits.id is 'Уникальный код';
		comment on column parameter_limits.parameter_id is 'Уникальный код типа параметра';
		comment on column parameter_limits.min_value is 'Минимальное значение';
		comment on column parameter_limits.max_value is 'Максимальное значение';
		comment on column parameter_limits.decimal_places is 'Допустимое число знаков после запятой';

		create table if not exists parameter_errors(
	    id integer not null,
	    code varchar(50) not null unique,
	    description varchar(255) not null
		);
		create sequence seq_parameter_errors;
		alter table parameter_errors alter column id set default nextval('seq_parameter_errors');

		comment on table parameter_errors is 'Справочник ошибок входных параметров';
		comment on column parameter_errors.id is 'Уникальный код';
		comment on column parameter_errors.code is 'Уникальный код ошибки';
		comment on column parameter_errors.description is 'Описание';
		
	exception when others then
		raise notice 'ошибка в транзакции 1: %', sqlerrm;
		raise;
	end;

end $$;
