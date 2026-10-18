do $$
begin
	begin
		drop type if exists interpolation_data cascade;
		create type interpolation_data as (
			x0 numeric,
			y0 numeric,
			x1 numeric,
			y1 numeric
		);

		comment on type interpolation_data is 'Точки для линейной интерполяции';
		comment on column interpolation_data.x0 is 'Левая опорная точка';
		comment on column interpolation_data.y0 is 'Значение в левой опорной точке';
		comment on column interpolation_data.x1 is 'Правая опорная точка';
		comment on column interpolation_data.y1 is 'Значение в правой опорной точке';

	exception when others then
		raise notice 'Ошибка в транзакции 1: %', sqlerrm;
		raise;
	end;

end $$
