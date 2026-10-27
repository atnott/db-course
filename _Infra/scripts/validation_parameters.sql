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
		drop function if exists check_parameters(parameter_list);
		create or replace function check_parameters(p parameter_list)
		returns text
		language plpgsql
		as $func$
		begin
		    return (
                select coalesce(string_agg(
                    case 
                        when v_val is null then pt.name || ': ' || err_missing.description
                        when r.decimal_places is not null and v_val <> round(v_val, r.decimal_places) then pt.name || ': ' || err_dec.description || ' (допустимо: ' || r.decimal_places || ')'
                        when v_val < r.min_value or v_val > r.max_value then pt.name || ': ' || err_range.description || ' (от ' || r.min_value || ' до ' || r.max_value || ')'
                    end, '; '), '')
                from (
                    values 
                        (1, p.height),
                        (2, p.temperature),
                        (3, p.pressure),
                        (4, p.wind_direction),
                        (5, p.wind_speed),
                        (6, p.drift_range)
                ) as vals(param_id, v_val)
                join parameter_limits r on r.eq_type_id = p.eq_type_id and r.parameter_id = vals.param_id
                join parameters pt on pt.id = r.parameter_id
                left join parameter_errors err_missing on err_missing.code = 'missing'
                left join parameter_errors err_range on err_range.code = 'range'
                left join parameter_errors err_dec on err_dec.code = 'decimals'
                where v_val is null 
                   or (r.decimal_places is not null and v_val <> round(v_val, r.decimal_places))
                   or v_val < r.min_value or v_val > r.max_value
            );
		end;
		$func$;
		
	exception when others then
        raise notice 'ошибка при создании функции check_parameters: %', sqlerrm;
        raise;
    end;

end $$;