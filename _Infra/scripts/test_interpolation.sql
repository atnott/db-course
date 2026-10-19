do $$
begin

	raise notice 'temperature=3 -> y=%', round(interpolate(3, get_interpolation_bounds(3)), 2);
	raise notice 'temperature=40 -> y=%', round(interpolate(40, get_interpolation_bounds(40)), 2);
	raise notice 'temperature=50 -> y=%', round(interpolate(50, get_interpolation_bounds(50)), 2);
	raise notice 'temperature=-50 -> y=%', round(interpolate(-50, get_interpolation_bounds(-50)), 2);

end $$;