with pack_parameters_pivot as (
    select
        p.id as pack_id,
        p.name as pack_name,
        u.equipment_type_id as eq_type_id,
        max(case when pp.parameter_id = 1 then pp.value::numeric end) as height,
        max(case when pp.parameter_id = 2 then pp.value::numeric end) as temperature,
        max(case when pp.parameter_id = 3 then pp.value::numeric end) as pressure,
        max(case when pp.parameter_id = 4 then pp.value::numeric end) as wind_direction,
        max(case when pp.parameter_id = 5 then pp.value::numeric end) as wind_speed,
        max(case when pp.parameter_id = 6 then pp.value::numeric end) as drift_range
    from packs p
    join users u on p.user_id = u.id
    left join pack_parameters pp on p.id = pp.pack_id
    group by p.id, p.name, u.equipment_type_id
),
pack_errors as (
    select
        ppp.*,
        check_parameters(cast(row(
            ppp.eq_type_id, ppp.height, ppp.temperature, ppp.pressure,
            ppp.wind_direction, ppp.wind_speed, ppp.drift_range
        ) as parameter_list)) as error_text
    from pack_parameters_pivot ppp
)
select
    pe.pack_name as "№",
    et.name as "Тип оборудования",
    pe.height as "Высота метеопоста",
    pe.temperature as "Температура",
    pe.pressure as "Давление",
    pe.wind_direction as "Направление ветра",
    pe.wind_speed as "Скорость ветра",
    pe.drift_range as "Дальность сноса пуль",
    (pe.error_text <> '') as "Флаг: Есть ошибка",
    nullif(pe.error_text, '') as "Описание ошибки"
from pack_errors pe
join equipment_types et on et.id = pe.eq_type_id
order by pe.pack_id;
