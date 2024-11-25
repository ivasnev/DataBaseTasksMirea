-- 1. Модифицировать структуру таблицы "Билет", разрешив хранить в поле "Номер вагона" значение больше 0
ALTER TABLE ticket
ADD CONSTRAINT car_number_positive CHECK (car_number > 0);

-- 2. В таблицу "Промежуточные станции" добавить столбец "Время стоянки" с типом INTERVAL
ALTER TABLE intermediate_stations
ADD COLUMN stop_duration INTERVAL;

-- 3. Создать новую таблицу "Физическое лицо"
CREATE TABLE physical_person (
    id BIGINT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    patronymic VARCHAR(50),
    passport_series BIGINT,
    passport_number BIGINT,
    birth_date DATE,
    gender CHAR(1)
);

-- 4. Для поля "Пол" добавить ограничение, разрешающее только "М" и "Ж"
ALTER TABLE physical_person
ADD CONSTRAINT chk_gender CHECK (gender IN ('М', 'Ж'));

-- 5. Создать таблицу "Покупка билета"
CREATE TABLE ticket_purchase (
    purchase_id BIGINT PRIMARY KEY,
    ticket_id BIGINT,
    person_id BIGINT,
    purchase_date DATE,
    return_date DATE DEFAULT NULL,
    FOREIGN KEY (ticket_id) REFERENCES ticket(id),
    FOREIGN KEY (person_id) REFERENCES physical_person(id)
);

-- 6. Удалить столбец "Статус" из таблицы "Билет"
ALTER TABLE ticket
DROP COLUMN status;

-- 7. Добавить таблицу "Бонусы"
CREATE TABLE bonuses (
    bonus_card_number BIGINT PRIMARY KEY,
    bonus_amount BIGINT,
    trips_count BIGINT
);

-- 8. Добавить внешний ключ в таблицу "Физические лица" к таблице "Бонусы"
ALTER TABLE physical_person
ADD COLUMN bonus_card_number BIGINT,
ADD CONSTRAINT fk_bonus_card FOREIGN KEY (bonus_card_number) REFERENCES bonuses(bonus_card_number);

-- 9. Установить значение по умолчанию для поля "Тип вагона" в таблице "Билет"
ALTER TABLE ticket
ALTER COLUMN car_type SET DEFAULT 1;

-- 10. Добавить столбец "Расстояние" в таблицу "Промежуточные станции"
ALTER TABLE intermediate_stations
ADD COLUMN distance_from_previous_station BIGINT;
