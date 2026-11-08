-- Домашняя работа от 2026-11-02
do $$
begin

	-- Создаем новые структуры
	begin
		
		-- Таблица стандартных высот
		drop table if exists calc_correction_heights cascade;
		drop sequence if exists calc_correction_height_seq;
		
		create sequence calc_correction_height_seq;
		create table calc_correction_heights
		(
		        id integer primary key not null default nextval('public.calc_correction_height_seq'),
		        height integer not null
		);
		
		
		insert into calc_correction_heights(height)
		values(200),(400),(800),(1200),(1600),(2000),(2400),(3000),(4000);
	
		comment on table calc_correction_heights is 'Таблица стандартных высот';
		comment on column calc_correction_heights.id is 'Уникальный код';
		comment on column calc_correction_heights.height is 'Высота';

		-- Справочник заголовков таблиц поправок
		drop table if exists calc_correction_headers cascade;
		drop sequence if exists calc_correction_headers_seq;
		create sequence calc_correction_headers_seq;
		create table calc_correction_headers (
			id integer not null primary key default nextval('calc_correction_headers_seq'),
			description text not null,
			header_values integer[] not null
		);
		insert into calc_correction_headers (description, header_values) values
		('Таблица 2, отклонение температуры', array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50]),
		('Таблица 3, скорость приземного ветра (ДМК)', array[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
		('Таблица 3, дальность сноса пуль (ВР)', array[40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150]);

		comment on table calc_correction_headers is 'Таблица заголовков';
		comment on column calc_correction_headers.description is 'Описание';
		comment on column calc_correction_headers.header_values is 'Значения';
	
		-- Справочник типов таблиц корректировок
		drop table if exists calc_correction_types cascade;
		drop sequence if exists calc_correction_types_seq;
		
		create sequence calc_correction_types_seq;
		create table calc_correction_types
		(
		        id integer not null primary key default nextval('public.calc_correction_types_seq'),
		        parent_id integer,
		        eq_type_id integer,
		        description text not null,
		        header_id integer references calc_correction_headers(id)
		);

		insert into calc_correction_types (id, description, parent_id, eq_type_id, header_id) values
		(1, 'Таблица 2, общая', null, null, 1),
		(2, 'Таблица 3, скорость среднего ветра', null, null, 2),
		(3, 'Таблица 3, направление среднего ветра', null, null, null),
		(4, 'Таблица 3, Скорость среднего ветра (ВР)', 2, 2, 3),
		(5, 'Таблица 3, Направление среднего ветра (ВР)',3, 2, null),
		(6, 'Таблица 3, Скорость среднего ветра (ДМК)', 2, 1, 2),
		(7, 'Таблица 3, Направление среднего ветра (ДМК)',3, 1, null),
		(8, 'Таблица 2, Положительные температуры', 1, null, 1),
		(9, 'Таблица 2, Отрицательные температуры', 1, null, 1);
	
		comment on table calc_correction_types is 'Справочник типов таблиц с собственными заголовками';
		comment on column calc_correction_types.id is 'Уникальный код';
		comment on column calc_correction_types.parent_id is 'Уникальный код владельца - тип таблицы';
		comment on column calc_correction_types.eq_type_id is 'Тип оборудования';
		comment on column calc_correction_types.description is 'Описание к таблице';
		comment on column calc_correction_types.header_id is 'Значения в заголовке таблице';

		-- Универсальная таблица корректировок
		drop table if exists calc_correction cascade;
		drop sequence if exists calc_correction_seq;
		
		create sequence calc_correction_seq;
		create table calc_correction
		(
		        id integer not null primary key default nextval('public.calc_correction_seq'),
		        height_id integer not null references calc_correction_heights(id),
        		type_id integer not null references calc_correction_types(id),
		        row_values integer[]
		);

		comment on table calc_correction is 'Универсальная таблица корректировок';
		comment on column calc_correction.id is 'Уникальный код';
		comment on column calc_correction.height_id is 'Код высоты';
		comment on column calc_correction.type_id is 'Код типа таблиц';
		comment on column calc_correction.row_values is 'Значения с корректировками';

		insert into calc_correction(height_id, type_id, row_values) values
		-- Отрицательные температуры (9)
		(1, 9, array[-1, -2, -3, -4, -5, -6, -7, -8, -8, -9, -20, -29, -39, -49]),
		(2, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -8, -9, -19, -29, -39, -48]),
		(3, 9, array[-1, -2, -3, -4, -5, -6, -6, -7, -7, -8, -18, -28, -37, -46]),
		(4, 9, array[-1, -2, -3, -4, -4, -5, -5, -6, -7, -8, -17, -26, -35, -44]),
		(5, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -7, -7, -17, -25, -34, -42]),
		(6, 9, array[-1, -2, -3, -3, -4, -4, -5, -6, -6, -7, -16, -24, -32, -40]),
		(7, 9, array[-1, -2, -2, -3, -4, -4, -5, -5, -6, -7, -15, -23, -31, -38]),
		(8, 9, array[-1, -2, -2, -3, -4, -4, -4, -5, -5, -6, -15, -22, -30, -37]),
		(9, 9, array[-1, -2, -2, -3, -4, -4, -4, -4, -5, -6, -14, -20, -27, -34]),
		-- Положительные температуры (8)
		(1, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 39, 49]),
		(2, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 38, 48]),
		(3, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 37, 46]),
		(4, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 35, 44]),
		(5, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 34, 42]),
		(6, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 32, 40]),
		(7, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 31, 38]),
		(8, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 30, 37]),
		(9, 8, array[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 27, 34]),
		-- Скорость ветра ВР (4)
		(1, 4, array[3, 4, 5, 6, 7, 7, 8, 9, 10, 11, 12, 12]),
		(2, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
		(3, 4, array[4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16]),
		(4, 4, array[4, 5, 7, 8, 8, 9, 11, 12, 13, 15, 15, 16]),
		(5, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 15, 17, 17]),
		(6, 4, array[4, 6, 7, 8, 9, 10, 11, 13, 14, 16, 17, 18]),
		(7, 4, array[4, 6, 8, 9, 9, 10, 12, 14, 15, 16, 18, 19]),
		(8, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 15, 17, 18, 19]),
		(9, 4, array[5, 6, 8, 9, 10, 11, 12, 14, 16, 18, 19, 20]),
		-- Направление ветра ВР (5)
		(1, 5, array[0]), (2, 5, array[1]), (3, 5, array[2]), (4, 5, array[2]),
		(5, 5, array[3]), (6, 5, array[3]), (7, 5, array[3]), (8, 5, array[4]), (9, 5, array[4]),
		-- Скорость ветра ДМК (6)
		(1, 6, array[4,6,8,9,10,12,14,15,16,18,20,21,22]),
		(2, 6, array[5,7,10,11,12,14,17,18,20,22,23,25,27]),
		(3, 6, array[5,8,10,11,13,15,18,19,21,23,25,27,28]),
		(4, 6, array[5,8,11,12,13,16,19,20,23,24,26,28,30]),
		(5, 6, array[6, 8, 11, 13, 14, 17, 20, 21, 23, 25, 27, 29, 32]),
		(6, 6, array[6, 9, 11, 13, 14, 17, 20, 21, 24, 26, 28, 30, 32]),
		(7, 6, array[6, 9, 12, 14, 15, 18, 21, 22, 25, 27, 29, 32, 34]),
		(8, 6, array[6, 9, 12, 14, 15, 18, 21, 23, 25, 28, 30, 32, 36]),
		(9, 6, array[6, 10, 12, 14, 16, 19, 22, 24, 26, 29, 32, 34, 36]),
		-- Направление ветра ДМК (7)
		(1, 7, array[1]), (2, 7, array[2]), (3, 7, array[3]), (4, 7, array[3]),
		(5, 7, array[4]), (6, 7, array[4]), (7, 7, array[4]), (8, 7, array[5]), (9, 7, array[5]);

	end;	

	-- Прочее
	begin
		-- Наименование подправлю
		-- drop table if exists calc_correction_temperature cascade;
		-- alter table public.temp_numeric_corrections rename to calc_correction_temperature;
		
				
		CREATE OR REPLACE FUNCTION public.fn_calc_temperature_interpolation(
			par_temperature numeric)
		    RETURNS numeric
		    LANGUAGE 'plpgsql'
		    COST 100
		    VOLATILE PARALLEL UNSAFE
		AS $BODY$
				        declare 
				                var_interpolation interpolation_data;
				                var_result numeric(8,2) default 0;
				                var_min_temparure numeric(8,2) default 0;
				                var_max_temperature numeric(8,2) default 0;
				                var_denominator numeric(8,2) default 0;
				        begin
				
				                                raise notice 'Расчет интерполяции для температуры %', par_temperature;
				
				                -- Проверим, возможно температура совпадает со значением в справочнике
				                if exists (select 1 from public.calc_correction_temperature where temperature = par_temperature ) then
				                begin
				                        select correction 
				                        into  var_result 
				                        from  public.calc_correction_temperature
				                        where 
				                                temperature = par_temperature;
				                end;
				                else    
				                begin
				                        -- Получим диапазон в котором работают поправки
				                        select min(temperature), max(temperature) 
				                        into var_min_temparure, var_max_temperature
				                        from public.calc_correction_temperature;
				
				                        if par_temperature < var_min_temparure or   
				                           par_temperature > var_max_temperature then
				
				                                raise exception 'Некорректно передан параметр! Невозможно рассчитать поправку. Значение должно укладываться в диаппазон: %, %',
				                                        var_min_temparure, var_max_temperature;
				                        end if;   
				
				                        -- Получим граничные параметры
				
				                        select x0, y0, x1, y1 
				                                                 into var_interpolation.x0, var_interpolation.y0, var_interpolation.x1, var_interpolation.y1
				                        from
				                        (
				                                select t1.temperature as x0, t1.correction as y0
				                                from public.calc_correction_temperature as t1
				                                where t1.temperature <= par_temperature
				                                order by t1.temperature desc
				                                limit 1
				                        ) as leftPart
				                        cross join
				                        (
				                                select t1.temperature as x1, t1.correction as y1
				                                from public.calc_correction_temperature as t1
				                                where t1.temperature >= par_temperature
				                                order by t1.temperature 
				                                limit 1
				                        ) as rightPart;
				
				                        raise notice 'Граничные значения %', var_interpolation;
				                        var_result :=  fn_calc_interpolation( par_temperature,  var_interpolation);
				                                                 
				                end;
				                end if;
				
				                                return var_result;
				
				end;
				
		$BODY$;
		
		-- ALTER FUNCTION public.fn_calc_temperature_interpolation(numeric)
		--     OWNER TO admin;
		
		COMMENT ON FUNCTION public.fn_calc_temperature_interpolation(numeric)
		    IS 'Функция для расчета интерполяции для метео приближенный';
	end;

	commit;
	
end $$;
	