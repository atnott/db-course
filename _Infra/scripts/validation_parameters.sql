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

end $$;
