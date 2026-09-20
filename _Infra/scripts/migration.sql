DROP TABLE IF EXISTS ranks CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS equipment_types CASCADE;
DROP TABLE IF EXISTS parameters CASCADE;
DROP TABLE IF EXISTS packs CASCADE;

CREATE TABLE ranks(
id SERIAL PRIMARY KEY,
code VARCHAR(50) NOT NULL UNIQUE,
title VARCHAR(150) NOT NULL
);

CREATE TABLE users(
id SERIAL PRIMARY KEY,
code VARCHAR(50) NOT NULL UNIQUE,
full_name VARCHAR(150) NOT NULL,
rank_id INT REFERENCES ranks(id) ON DELETE SET NULL
);

CREATE TABLE equipment_types(
id SERIAL PRIMARY KEY,
code VARCHAR(50) NOT NULL UNIQUE,
name VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE parameters(
id SERIAL PRIMARY KEY,
code VARCHAR(50) NOT NULL UNIQUE,
name VARCHAR(150) NOT NULL UNIQUE,
unit VARCHAR(50),
equipment_type_id INT REFERENCES equipment_types(id) ON DELETE SET NULL
);

CREATE TABLE packs(
id SERIAL PRIMARY KEY,
code VARCHAR(50) NOT NULL UNIQUE,
created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
user_id INT REFERENCES users(id) ON DELETE CASCADE,
equipment_type_id INT REFERENCES equipment_types(id) ON DELETE CASCADE
);

INSERT INTO ranks (code, title) VALUES
('POS-METEO', 'Оператор метеопоста'),
('POS-ART', 'Вычислитель артиллерийского дивизиона');

INSERT INTO users (code, full_name, rank_id) VALUES
('USR-01', 'Смирнов Алексей Игоревич', 1),
('USR-02', 'Ковалев Дмитрий Сергеевич', 2);

INSERT INTO equipment_types (code, name) VALUES
('EQ-DMK', 'Десантный метеокомплект'),
('EQ-VR', 'Ветровое ружье');

INSERT INTO parameters (code, name, unit, equipment_type_id) VALUES
('P-HEIGHT', 'Высота метеопоста', 'м', 1),
('P-TEMP', 'Температура воздуха', '°C', 1),
('P-PRESS', 'Давление атмосферы', 'мм рт. ст.', 1),
('P-WDIR', 'Направление ветра', 'д.у.', 1),
('P-WSPEED', 'Скорость ветра', 'м/с', 1),
('P-DRIFT', 'Дальность сноса пуль', 'м', 2);

INSERT INTO packs (code, user_id, equipment_type_id) VALUES
('METEO11-24093-01', 1, 1),
('METEO11-24093-02', 2, 2);

SELECT
	pk.code AS "Код бюллетеня",
    pk.created_at AS "Дата/время замера",
    u.full_name AS "Оператор",
    r.title AS "Должность",
    eq.name AS "Оборудование",
    p.code AS "Код параметра",
    p.name AS "Наименование параметра",
    p.unit AS "Единица измерения"
FROM packs pk
JOIN users u ON pk.user_id = u.id
LEFT JOIN ranks r ON u.rank_id = r.id
JOIN equipment_types eq ON pk.equipment_type_id = eq.id
LEFT JOIN parameters p ON p.equipment_type_id = eq.id
ORDER BY pk.id, p.id;

