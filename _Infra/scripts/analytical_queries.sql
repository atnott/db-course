-- 1. количество пачек по пользователям
select
	users.id as user_id,
	users.name as user_name,
	COUNT(packs.id) as total_packs
from users
left join packs on users.id = packs.user_id
group by users.id;

-- 2. поиск пустых пачек
select
	p.id as pack_id,
	p.name as pack_name,
	p.created_at,
	p.user_id
from packs p
left join pack_parameters pp on p.id = pp.pack_id
where pp.id is null;

-- 3. проверка полноты комплекта параметров
select
    p.id as pack_id,
    p.name as pack_name,
    count(pp.parameter_id) as parameters_count
from packs p
left join pack_parameters pp on p.id = pp.pack_id
group by p.id, p.name
having count(pp.parameter_id) <> 6
order by p.id;

-- 4. проверка значений параметров на соответствие диапазонам тз
select
    pp.id as record_id,
    p.id as pack_id,
    p.name as pack_name,
    param.name as parameter_name,
    pp.value as actual_value,
    case
        when param.id = 2 and (pp.value::numeric < -58 or pp.value::numeric > 58)
            then 'Температура вне диапазона (-58..58 °C)'
        when param.id = 3 and (pp.value::numeric < 500 or pp.value::numeric > 900)
            then 'Давление вне диапазона (500..900 мм рт.ст.)'
        when param.id = 4 and (pp.value::numeric < 0 or pp.value::numeric > 59)
            then 'Направление ветра вне диапазона (0..59 ДУ)'
        when param.id = 5 and (pp.value::numeric < 0 or pp.value::numeric > 15)
            then 'Скорость ветра вне диапазона (0..15 м/с)'
        when param.id = 6 and (pp.value::numeric < 0 or pp.value::numeric > 150)
            then 'Дальность сноса пуль вне диапазона (0..150 м)'
        else 'Корректно'
    end as anomaly_description
from pack_parameters pp
join packs p on pp.pack_id = p.id
join parameters param on pp.parameter_id = param.id
where
    (param.id = 2 and (pp.value::numeric < -58 or pp.value::numeric > 58))
    or (param.id = 3 and (pp.value::numeric < 500 or pp.value::numeric > 900))
    or (param.id = 4 and (pp.value::numeric < 0 or pp.value::numeric > 59))
    or (param.id = 5 and (pp.value::numeric < 0 or pp.value::numeric > 15))
    or (param.id = 6 and (pp.value::numeric < 0 or pp.value::numeric > 150));

-- 5. проверка соответствия единиц измерения базовым величинам
select
    pp.id as record_id,
    p.id as pack_id,
    p.name as pack_name,
    param.name as parameter_name,
    u.name as unit_name,
    bu.name as base_unit_name,
    case
        when param.id = 2 and bu.id != 2 then 'Для температуры должна быть базовая единица Температура'
        when param.id = 3 and bu.id != 3 then 'Для давления должна быть базовая единица Давление'
        when param.id = 4 and bu.id != 4 then 'Для направления ветра должна быть базовая единица Угол'
        when param.id = 5 and bu.id != 5 then 'Для скорости ветра должна быть базовая единица Скорость'
        when param.id = 6 and bu.id != 1 then 'Для дальности сноса должна быть базовая единица Длина'
        else 'Корректно'
    end as unit_anomaly
from pack_parameters pp
join packs p on pp.pack_id = p.id
join parameters param on pp.parameter_id = param.id
join units u on param.unit_id = u.id
join base_units bu on u.base_unit_id = bu.id
where
    (param.id = 2 and bu.id != 2)
    or (param.id = 3 and bu.id != 3)
    or (param.id = 4 and bu.id != 4)
    or (param.id = 5 and bu.id != 5)
    or (param.id = 6 and bu.id != 1);