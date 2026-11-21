DROP TABLE IF EXISTS ranks CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS equipment_types CASCADE;
DROP TABLE IF EXISTS parameters CASCADE;
DROP TABLE IF EXISTS packs CASCADE;
DROP TABLE IF EXISTS pack_parameters CASCADE;

CREATE TABLE ranks(
id INT PRIMARY KEY,
title VARCHAR(150) NOT NULL
);

COMMENT ON TABLE ranks IS 'Таблица должностей';
COMMENT ON COLUMN ranks.id IS 'Уникальный код должностей';
COMMENT ON COLUMN ranks.title IS 'Наименование должности';

CREATE TABLE equipment_types(
id INT PRIMARY KEY,
name VARCHAR(150) NOT NULL
);

COMMENT ON TABLE equipment_types is 'Таблица типов оборудования';
COMMENT ON COLUMN equipment_types.id is 'Уникальный код типа оборудования';
COMMENT ON COLUMN equipment_types.name is 'Наименование типа оборудования';

CREATE TABLE parameters(
id INT PRIMARY KEY,
name VARCHAR(150) NOT NULL UNIQUE
);

COMMENT ON TABLE parameters is 'Таблица параметров';
COMMENT ON COLUMN parameters.id is 'Уникальный код параметра';
COMMENT ON COLUMN parameters.name is 'Наименование параметра';

CREATE TABLE users(
id INT PRIMARY KEY,
name VARCHAR(150) NOT NULL,
rank_id INT REFERENCES ranks(id),
equipment_type_id INT REFERENCES equipment_types(id)
);

COMMENT ON TABLE users is 'Таблица пользователей';
COMMENT ON COLUMN users.id is 'Уникальный код пользователя';
COMMENT ON COLUMN users.name is 'Имя пользователя';
COMMENT ON COLUMN users.rank_id is 'Код должности';
COMMENT ON COLUMN users.equipment_type_id is 'Код оборудования';

CREATE TABLE packs(
id INT PRIMARY KEY,
name VARCHAR(150) NOT NULL,
created_at DATE,
user_id INT REFERENCES users(id)
);

COMMENT ON TABLE packs is 'Журнал для записей';
COMMENT ON COLUMN packs.id is 'Уникальный код пачки';
COMMENT ON COLUMN packs.created_at is 'Дата измерения';
COMMENT ON COLUMN packs.user_id is 'Ссылка на пользователя';
COMMENT ON COLUMN packs.name is 'Название';

CREATE TABLE pack_parameters(
id INT PRIMARY KEY,
pack_id INT REFERENCES packs(id),
parameter_id INT REFERENCES parameters(id),
value VARCHAR(50) NOT NULL
);

COMMENT ON TABLE pack_parameters is 'Значения параметров для журнала';
COMMENT ON COLUMN pack_parameters.value is 'Значение замера';
COMMENT ON COLUMN pack_parameters.id is 'Уникальный код записи';
COMMENT ON COLUMN pack_parameters.pack_id is 'Ссылка на пачку';
COMMENT ON COLUMN pack_parameters.parameter_id is 'Ссылка на параметр';

INSERT INTO ranks (id, title) VALUES 
(1, 'Оператор метеопоста'),
(2, 'Вычислитель артиллерийского дивизиона');

INSERT INTO equipment_types (id, name) VALUES 
(1, 'Десантный метеокомплект (ДМК)'),
(2, 'Ветровое ружье');

INSERT INTO users (id, name, rank_id, equipment_type_id) VALUES 
(1, 'Смирнов Алексей Игоревич', 1, 1),
(2, 'Ковалев Дмитрий Сергеевич', 2, 2);

INSERT INTO packs (id, name, created_at, user_id) VALUES 
(1, '24093', '2026-09-20', 1);

INSERT INTO parameters (id, name) VALUES 
(1, 'Высота метеопоста'),
(2, 'Температура воздуха'),
(3, 'Давление атмосферы'),
(4, 'Направление ветра'),
(5, 'Скорость ветра'),
(6, 'Дальность сноса пуль');

INSERT INTO pack_parameters (id, pack_id, parameter_id, value) VALUES 
(1, 1, 1, '100'),
(2, 1, 2, '15'),
(3, 1, 3, '750'),
(4, 1, 4, '00'),
(5, 1, 5, '5'),
(6, 1, 6, '0');

SELECT 
	u.name AS user_name,
	p.name AS pack_name,
	p.created_at AS pack_date,
	r.title AS rank_title,
	eq.name AS equipment_name,
	param.name AS parameter_name,
	pp.value AS parameter_value
FROM users u 
JOIN packs p ON u.id = p.user_id
JOIN ranks r ON u.rank_id = r.id
JOIN equipment_types eq ON u.equipment_type_id = eq.id
JOIN pack_parameters pp ON p.id = pp.pack_id
JOIN parameters param ON pp.parameter_id = param.id;
