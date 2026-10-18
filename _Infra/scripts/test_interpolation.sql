do $$
declare
	p1 interpolation_data;
	p2 interpolation_data;
	y1 numeric;
	y2 numeric;
begin

	p1 := get_interpolation_bounds(3);
	p2 := get_interpolation_bounds(40);

	y1 := interpolate(3, p1);
	y2 := interpolate(40, p2);

	raise notice 'temperature=3 -> y=%', round(y1, 2);
	raise notice 'temperature=40 -> y=%', round(y2, 2);

end $$;