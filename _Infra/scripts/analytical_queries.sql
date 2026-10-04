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

SELECT
    p.id AS pack_id,
    p.name AS pack_name,
    COUNT(pp.parameter_id) AS parameters_count
FROM packs p
LEFT JOIN pack_parameters pp ON p.id = pp.pack_id
GROUP BY p.id, p.name
HAVING COUNT(pp.parameter_id) <> 6
ORDER BY p.id;