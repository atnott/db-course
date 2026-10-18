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
		create temporary table temp_numeric_corrections (
			temperature numeric not null,
			correction numeric not null
		);

		insert into temp_numeric_corrections (temperature, correction) values
			(0, 0.0),
			(5, 0.5),
			(10, 1.0),
			(15, 1.0),
			(20, 1.5),
			(25, 2.0),
			(30, 3.5),
			(40, 4.5);

		comment on table temp_numeric_corrections is 'Опорные точки';
		comment on column temp_numeric_corrections.temperature is 'Температура';
		comment on column temp_numeric_corrections.correction is 'Поправка';

	exception when others then
		raise notice 'Ошибка в транзакции 2: %', sqlerrm;
		raise;
	end;

	begin
		create or replace function get_interpolation_bounds(p_temperature numeric)
		returns interpolation_data
		language plpgsql
		as $func$
		declare
			result interpolation_data;
		begin

			if p_temperature < 0 then
				result.x0 := -50;
				result.y0 := 0;
				result.x1 := 0;
				result.y1 := 0;
				return result;
			end if;

			select temperature, correction
			into result.x0, result.y0
			from temp_numeric_corrections
			where temperature <= p_temperature
			order by temperature desc
			limit 1;

			select temperature, correction
			into result.x1, result.y1
			from temp_numeric_corrections
			where temperature >= p_temperature
			order by temperature asc
			limit 1;

			if result.x1 is null then
				result.x1 := 58;
				result.y1 := result.y0;
			end if;

			return result;
					
		end;
		$func$;
        
	exception when others then
		raise notice 'Ошибка в транзакции 3: %', sqlerrm;
		raise;
	end;
end $$