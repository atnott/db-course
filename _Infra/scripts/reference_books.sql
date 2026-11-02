do $$
begin

    begin
        drop table if exists standard_heights cascade;
        drop table if exists height_temperature_deviations cascade;

        drop sequence if exists seq_standard_heights;
        drop sequence if exists seq_height_temperature_deviations;

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

    exception when others then
        raise notice 'Ошибка в транзакции: %', sqlerrm;
        raise;
    end;

end $$;