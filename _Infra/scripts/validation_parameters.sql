do $$
begin

    begin
        drop type if exists parameter_list cascade;
        create type parameter_list as (
            eq_type_id integer,
            height numeric,
            temperature numeric,
            pressure numeric,
            wind_direction numeric,
            wind_speed numeric,
            drift_range numeric
        );

        comment on type parameter_list is 'Список входных параметров для проверки';
        comment on column parameter_list.eq_type_id is 'ID типа оборудования';
        comment on column parameter_list.height is 'Высота метеопоста';
        comment on column parameter_list.temperature is 'Температура';
        comment on column parameter_list.pressure is 'Давление';
        comment on column parameter_list.wind_direction is 'Направление ветра';
        comment on column parameter_list.wind_speed is 'Скорость ветра';
        comment on column parameter_list.drift_range is 'Дальность сноса пуль';

    exception when others then
        raise notice 'ошибка при создании типа parameter_list: %', sqlerrm;
        raise;
    end;


	begin
		create or replace function check_parameters(p parameter_list)
		returns text
		language plpgsql
		as $func$
        declare
            r record;
			v_val numeric;
			v_errors text := '';
    		v_single_error text;
		begin
			for r in 
		        select l.parameter_id, l.min_value, l.max_value, l.decimal_places, pt.short_name
		        from parameter_limits l
		        join parameters pt on pt.id = l.parameter_id
		        where l.eq_type_id = p.eq_type_id
	    	loop
				v_val := case r.parameter_id
		            when 1 then p.height
		            when 2 then p.temperature
		            when 3 then p.pressure
		            when 4 then p.wind_direction
		            when 5 then p.wind_speed
		            when 6 then p.drift_range
		        end;

				v_single_error := null;

				if v_val is null then
            		v_single_error := r.short_name || ': значение не задано';

				elsif r.decimal_places is not null and v_val <> round(v_val, r.decimal_places) then
            		v_single_error := r.short_name || ': неверное число знаков (допустимо: ' || r.decimal_places || ')';

				elsif v_val < r.min_value or v_val > r.max_value then
		            v_single_error := r.short_name || ': вне диапазона (от ' || r.min_value || ' до ' || r.max_value || ')';
		        end if;

				if v_single_error is not null then
					if v_errors = '' then
		                v_errors := v_single_error;
		            else
						v_errors := v_errors || '; ' || v_single_error;
					end if;
				end if;
			end loop;
			
			return v_errors;
		end;
		$func$;
		
	exception when others then
        raise notice 'ошибка при создании функции check_parameters: %', sqlerrm;
        raise;
    end;

end $$;