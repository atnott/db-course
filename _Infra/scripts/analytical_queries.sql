select
	users.id as user_id,
	users.name as user_name,
	COUNT(packs.id) as total_packs
from users
left join packs on users.id = packs.user_id
group by users.id