do $$
begin

    begin
        drop table if exists height_wind_angles;
        drop table if exists height_wind_average_speeds;
        drop table if exists height_temperature_deviations;
        drop table if exists standard_heights;

        drop sequence if exists seq_standard_heights;
        drop sequence if exists seq_height_temperature_deviations;
        drop sequence if exists seq_height_wind_average_speeds;
        drop sequence if exists seq_height_wind_angles;

        create table standard_heights (
            id integer primary key,
            height_y integer not null unique,
            code_str varchar(2) not null,
            constraint check_positive_height check (height_y > 0)
        );
        create sequence seq_standard_heights;
        alter table standard_heights alter column id set default nextval('seq_standard_heights');

        comment on table standard_heights is 'Стандартные высоты для Y';
        comment on column standard_heights.height_y is 'Высота слоя, метры';
        comment on column standard_heights.code_str is 'Код высоты в бюллетене';

        create table height_temperature_deviations (
            id integer primary key,
            height_id integer references standard_heights(id) on delete cascade,
            delta_tau integer not null,
            deviation_val integer not null,
            constraint unique_height_tau unique (height_id, delta_tau)
        );
        create sequence seq_height_temperature_deviations;
        alter table height_temperature_deviations alter column id set default nextval('seq_height_temperature_deviations');

        comment on table height_temperature_deviations is 'Средние отклонения температуры воздуха';
        comment on column height_temperature_deviations.height_id is 'Уникальный ключ стандартной высоты';
        comment on column height_temperature_deviations.delta_tau is 'Отклонение приземной температуры';
        comment on column height_temperature_deviations.deviation_val is 'Итоговая поправка на высоте';

        create table height_wind_average_speeds (
            id integer primary key,
            equipment_type_id integer not null references equipment_types(id) on delete cascade,
            height_id integer references standard_heights(id) on delete cascade,
            input_value integer not null,
            avg_wind_speed integer not null,
            constraint uq_eq_height_input unique (equipment_type_id, height_id, input_value)
        );
        create sequence seq_height_wind_average_speeds;
        alter table height_wind_average_speeds alter column id set default nextval('seq_height_wind_average_speeds');

        comment on table height_wind_average_speeds is 'Скорость среднего ветра по высотам';
        comment on column height_wind_average_speeds.input_value is 'Скорость v0 для дмк или дальность сноса дг для вр';
        comment on column height_wind_average_speeds.avg_wind_speed is 'Выходное значение скорости среднего ветра';

        create table height_wind_angles (
            id integer primary key,
            equipment_type_id integer not null references equipment_types(id) on delete cascade,
            height_id integer references standard_heights(id) on delete cascade,
            angle_increase integer not null,
            constraint uq_eq_height_angle unique (equipment_type_id, height_id)
        );
        create sequence seq_height_wind_angles;
        alter table height_wind_angles alter column id set default nextval('seq_height_wind_angles');

        comment on table height_wind_angles is 'Приращение дирекционного угла ветра по высотам';
        comment on column height_wind_angles.angle_increase is 'в делениях угломера';

    exception when others then
        raise notice 'Ошибка в транзакции: %', sqlerrm;
        raise;
    end;

end $$;