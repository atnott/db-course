do $$
begin
    create or replace function calc_ddchm(p_wind_speed numeric, p_wind_direction numeric)
    returns numeric
    language plpgsql
    as $func$
    begin
        if p_wind_speed is null or p_wind_direction is null then
            return 0.0;
        end if;
        
        return round((p_wind_speed * cos(p_wind_direction * pi() / 30.0))::numeric, 2);
    end;
    $func$;

    create or replace function calc_vvvv(p_temperature numeric, p_height numeric)
    returns numeric
    language plpgsql
    as $func$
    begin
        if p_temperature is null or p_height is null then
            return 0.0;
        end if;

        return round(((p_temperature - 15.0) * 0.1 + (p_height / 100.0) * 0.05)::numeric, 2);
    end;
    $func$;

    create or replace function calc_bbtt(p_pressure numeric)
    returns numeric
    language plpgsql
    as $func$
    begin
        if p_pressure is null then
            return 0.0;
        end if;

        return round(((p_pressure - 750.0) * 0.02)::numeric, 2);
    end;
    $func$;

    comment on function calc_ddchm(numeric, numeric) is 'Расчет метео ДДЧМ';
    comment on function calc_vvvv(numeric, numeric) is 'Расчет метео ВВВВ';
    comment on function calc_bbtt(numeric) is 'Расчет метео ББТТ';

exception when others then
    raise notice 'ошибка при создании функций расчета метео: %', sqlerrm;
    raise;
end $$;
