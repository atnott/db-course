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

	begin
		create or replace function get_interpolation_bounds(temperature numeric)
		returns interpolation_data
		language plpgsql
		as $func$
		declare
			result interpolation_data;
		begin
			case
				when temperature < 0 then
					result.x0 := -100;
					result.y0 := 0;
					result.x1 := 0;
					result.y1 := 0;
				when temperature >= 0 and temperature < 5 then
					result.x0 := 0;
					result.y0 := 0;
					result.x1 := 5;
					result.y1 := 0.5;
				when temperature >= 5 and temperature < 10 then
					result.x0 := 5;
					result.y0 := 0.5;
					result.x1 := 10;
					result.y1 := 1;
				when temperature >= 10 and temperature < 15 then
					result.x0 := 10;
					result.y0 := 1;
					result.x1 := 15;
					result.y1 := 1;
				when temperature >= 15 and temperature < 20 then
					result.x0 := 15;
					result.y0 := 1;
					result.x1 := 20;
					result.y1 := 1.5;
				when temperature >= 20 and temperature < 25 then
					result.x0 := 20;
					result.y0 := 1.5;
					result.x1 := 25;
					result.y1 := 2;
				when temperature >= 25 and temperature < 30 then
					result.x0 := 25;
					result.y0 := 2;
					result.x1 := 30;
					result.y1 := 3.5;
				when temperature >= 30 and temperature <= 40 then
					result.x0 := 30;
					result.y0 := 3.5;
					result.x1 := 40;
					result.y1 := 4.5;
				else
					result.x0 := 40;
					result.y0 := 4.5;
					result.x1 := 100;
					result.y1 := 4.5;
			 end case;
			 return result;
		end;
		$func$;
	end;
end $$
