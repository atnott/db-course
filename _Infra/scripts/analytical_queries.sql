select
	users.id as user_id,
	users.name as user_name,
	COUNT(packs.id) as total_packs
from users
left join packs on users.id = packs.user_id
group by users.id

select
	p.id as pack_id,
	p.name as pack_name,
	p.created_at,
	p.user_id
from packs p
left join pack_parameters pp on p.id = pp.pack_id
where pp.id is null