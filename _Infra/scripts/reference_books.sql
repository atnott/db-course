do $$
begin

    begin
        drop table if exists standard_heights cascade;

        drop sequence if exists seq_standard_heights;

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

    exception when others then
        raise notice 'Ошибка в транзакции: %', sqlerrm;
        raise;
    end;

end $$;