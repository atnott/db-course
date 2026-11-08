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

	begin

		-- Финальная функция расчета
		create or replace function calc_meteo_average(p_parameters parameter_list, p_eq_type_id integer)
		returns table (
		    height integer,
		    temperature_deviation text,
		    wind_direction text,
		    wind_speed integer
		)
		language plpgsql
		as $func$
		declare
		    v_errors text;
		    v_deviation integer;
		    v_dmk_id integer;
		    v_argument numeric;
		    v_speed_type_id integer;
		    v_direction_type_id integer;
		    v_threshold integer;
		    v_height record;
		    v_total integer;
		    v_speed numeric;
		    v_increment integer;
		    
		    v_neg_temp_base numeric;
		    v_wind_circle numeric;
			
		begin
		    -- Читаем константы из таблицы constants
		    select value into v_neg_temp_base from constants where code = 'negative_temperature_base';
		    if v_neg_temp_base is null then v_neg_temp_base := 50; end if;
		
		    select value into v_wind_circle from constants where code = 'wind_circle_grad';
		    if v_wind_circle is null then v_wind_circle := 60; end if;
		
		    -- Проверка параметров
		    v_errors := check_parameters(cast(row(
		        p_eq_type_id, p_parameters.height, p_parameters.temperature, p_parameters.pressure,
		        p_parameters.wind_direction, p_parameters.wind_speed, p_parameters.drift_range
		    ) as parameter_list));
		
		    if v_errors <> '' then
		        raise exception 'Некорректные входные параметры: %', v_errors;
		    end if;
		
		    -- Расчет отклонения приземной виртуальной температуры
		    v_deviation := cast(round(
		        p_parameters.temperature
		        + interpolate(p_parameters.temperature, get_interpolation_bounds(p_parameters.temperature))
		        - get_meteo_constant('table_temperature')
		    ) as integer);
		
		    -- Определение аргумента для Таблицы 3
		    select id into v_dmk_id from equipment_types where name ilike '%ДМК%';
		    if v_dmk_id is null then v_dmk_id := 1; end if;
		    
		    v_argument := case when p_eq_type_id = v_dmk_id then p_parameters.wind_speed else p_parameters.drift_range end;
		
		    -- Получаем типы таблиц для скорости и направления ветра
		    select t.id into v_speed_type_id
		    from calc_correction_types t
		    inner join calc_correction_types p on p.id = t.parent_id
		    where p.code = 'wind_speed' and t.eq_type_id = p_eq_type_id;
		
		    select t.id into v_direction_type_id
		    from calc_correction_types t
		    inner join calc_correction_types p on p.id = t.parent_id
		    where p.code = 'wind_direction' and t.eq_type_id = p_eq_type_id;
		
		    -- Порог обнуления ветра
		    select h.header_values[1] into v_threshold
		    from calc_correction_types t
		    inner join calc_correction_headers h on h.id = t.header_id
		    where t.id = v_speed_type_id;
		
		    for v_height in
		        select h.id, h.height
		        from calc_correction_heights h
		        order by h.height
		    loop
		        height := v_height.height;
		
		        -- Расчет отклонения температуры 
		        v_total := calc_temperature_average_deviation(v_height.id, v_deviation);
		        if v_total < 0 then
		            temperature_deviation := lpad(cast(v_neg_temp_base + abs(v_total) as text), 2, '0');
		        else
		            temperature_deviation := lpad(cast(v_total as text), 2, '0');
		        end if;
		
		        -- Проверка порога ветра и расчет скорости и направления
		        if v_argument < v_threshold then
		            wind_direction := '00';
		            wind_speed := 0;
		        else
		            v_speed := get_correction_value(v_height.id, v_speed_type_id, v_argument);
		
		            select c.row_values[1] into v_increment
		            from calc_correction c
		            where c.height_id = v_height.id and c.type_id = v_direction_type_id;
		
		            wind_speed := cast(round(v_speed) as integer);
		            wind_direction := lpad(cast(mod(cast(p_parameters.wind_direction as integer) + coalesce(v_increment, 0), v_wind_circle::integer) as text), 2, '0');
		        end if;
		
		        return next;
		    end loop;
			
		end;
		$func$;

	end;

	begin

		-- Вспомогательные функции форматирования
		create or replace function public.fn_format_h(par_height integer) 
		returns text language plpgsql as $body$
		begin
		    return lpad((par_height / 100)::text, 2, '0');
		end;
		$body$;
		
		create or replace function public.fn_format_tt(par_t integer) 
		returns text language plpgsql as $body$
		begin
		    if par_t < 0 then 
		        return lpad((50 + abs(par_t))::text, 2, '0'); 
		    end if;
		    return lpad(par_t::text, 2, '0');
		end;
		$body$;
		
		create or replace function public.fn_format_hh(par_dir integer, par_circle integer) 
		returns text language plpgsql as $body$
		begin
		    return lpad((par_dir % par_circle)::text, 2, '0');
		end;
		$body$;
		
		create or replace function public.fn_format_cc(par_speed integer) 
		returns text language plpgsql as $body$
		begin
		    return lpad(par_speed::text, 2, '0');
		end;
		$body$;

	end;

	begin

		create or replace procedure public.pr_calc_meteo_average(par_params parameter_list, par_equipment_id integer) 
		language plpgsql as $body$
		declare
		    var_dt integer;
		    var_tens integer;
		    var_units integer;
		    var_wind integer;
		    var_h record;
		    var_t integer;
		    var_dir integer;
		    var_speed integer;
		    var_dcorr integer;
		    var_trow integer[];
		    var_srow integer[];
		    var_th integer[];
		    var_sh integer[];
		    var_min_dmk_wind numeric;
		    var_min_bp_drift numeric;
		    var_wind_circle numeric;
		    var_table_temp numeric;
		begin

		    select value into var_min_dmk_wind from constants where code = 'min_dmk_wind_speed';
		    if var_min_dmk_wind is null then var_min_dmk_wind := 3; end if;
		
		    select value into var_min_bp_drift from constants where code = 'min_bp_drift_range';
		    if var_min_bp_drift is null then var_min_bp_drift := 40; end if;
		
		    select value into var_wind_circle from constants where code = 'wind_circle_grad';
		    if var_wind_circle is null then var_wind_circle := 60; end if;
		
		    select value into var_table_temp from constants where code = 'table_temperature';
		    if var_table_temp is null then var_table_temp := 15.9; end if;

			var_dt := round(public.fn_calc_temperature_interpolation(par_params.temperature));
		    
		    var_tens := (abs(var_dt) / 10) * 10;
		    var_units := abs(var_dt) - var_tens;
		
		    if par_equipment_id = 1 then 
		        var_wind := par_params.wind_speed;
		    else
		        var_wind := round(par_params.drift_range / 10) * 10;
		    end if;
		
		    if (par_equipment_id = 1 and coalesce(par_params.wind_speed, 0) < var_min_dmk_wind) or 
		       (par_equipment_id = 2 and coalesce(par_params.drift_range, 0) < var_min_bp_drift) then
		        var_wind := null;
		    end if;
		
		    -- Получаем заголовок температуры

			select h.header_values into var_th
			from calc_correction_types t
			left join calc_correction_headers h on h.id = t.header_id
			where t.id = case when var_dt < 0 then 9 else 8 end;
	
			-- Получаем заголовок скорости ветра
			if var_wind is not null then
				select h.header_values into var_sh
				from calc_correction_types t
				left join calc_correction_headers h on h.id = t.header_id
				where t.parent_id = 2 and t.eq_type_id = par_equipment_id;
			end if;
		
		    for var_h in select id, height from calc_correction_heights order by height loop
		        select c.row_values into var_trow
		        from calc_correction c
		        where c.height_id = var_h.id and c.type_id = case when var_dt < 0 then 9 else 8 end;
		
		        var_t := coalesce(var_trow[array_position(var_th, var_tens)], 0) + coalesce(var_trow[array_position(var_th, var_units)], 0);
		
		        if var_wind is null then 
		            var_dir := 0; 
		            var_speed := 0;
		        else
		            select c.row_values into var_srow
		            from calc_correction c
		            join calc_correction_types t on t.id = c.type_id
		            where c.height_id = var_h.id and t.parent_id = 2 and t.eq_type_id = par_equipment_id;
		
		            var_speed := coalesce(var_srow[array_position(var_sh, var_wind)], 0);
		
		            select c.row_values[1] into var_dcorr
		            from calc_correction c
		            join calc_correction_types t on t.id = c.type_id
		            where c.height_id = var_h.id and t.parent_id = 3 and t.eq_type_id = par_equipment_id;
		
		            var_dir := (par_params.wind_direction::integer + coalesce(var_dcorr, 0))::integer % var_wind_circle::integer;
		        end if;
		
		        raise notice 'Высота: % | TT: % | HH: % | CC: %', 
		            public.fn_format_h(var_h.height), 
		            public.fn_format_tt(var_t), 
		            public.fn_format_hh(var_dir, var_wind_circle::integer), 
		            public.fn_format_cc(var_speed);
		    end loop;
		end;
		$body$;
	end;
	
end $$;
	