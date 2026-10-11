select
	row_number() over (order by name) as "№",
	name as "Наименование", 
	type as "Тип"
	from (
		select 
			table_name as name,
			'Таблица' as type
		from information_schema.tables
		where table_schema = 'public' and table_catalog = current_database()

		union all

		select
			sequence_name as name,
			'Счетчик' as type
		from information_schema.sequences
		where sequence_schema = 'public' and sequence_catalog = current_database()
	)