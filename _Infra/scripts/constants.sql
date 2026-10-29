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
		eq_type_id integer not null,
	    min_value numeric,
	    max_value numeric,
	    decimal_places integer
		);
		create sequence seq_parameter_limits;
		alter table parameter_limits alter column id set default nextval('seq_parameter_limits');

		comment on table parameter_limits is 'Допустимые значения входных параметров';
		comment on column parameter_limits.id is 'Уникальный код';
		comment on column parameter_limits.parameter_id is 'Уникальный код типа параметра';
		comment on column parameter_limits.eq_type_id is 'Уникальный код типа оборудования';
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

	begin
        insert into constants (code, value, description) values
            ('table_pressure', 750, 'Табличное значение наземного давления, мм рт. ст.'),
            ('table_temperature', 15.9, 'Табличное значение приземной виртуальной температуры, градусы Цельсия'),
            ('negative_pressure_base', 500, 'Число, к которому прибавляется модуль отрицательного отклонения давления'),
            ('negative_temperature_base', 50, 'Число, к которому прибавляется модуль отрицательного отклонения температуры');

        insert into parameter_errors (code, description) values
            ('missing', 'значение не задано'),
            ('range', 'значение вне допустимого диапазона'),
            ('decimals', 'недопустимое число знаков после запятой');

        insert into parameter_limits (parameter_id, eq_type_id, min_value, max_value, decimal_places) values
            (1, 1, null, null, 0),
			(1, 2, null, null, 0),
			(2, 1, -58, 58, 1),
			(2, 2, -58, 58, 1),
			(3, 1, 500, 900, 0),
			(3, 2, 500, 900, 0),
			(4, 1, 0, 59, 0),
			(4, 2, 0, 59, 0),
			(5, 1, 0, 15, 0),
			(6, 2, 0, 150, 0);

    exception when others then
        raise notice 'ошибка при заполнении констант: %', sqlerrm;
        raise;
    end;

end $$;