-- Таблица "Районы"
create table districts
(
    district_id   bigint primary key,
    district_name character varying(255)
);

-- Таблица "Тип объекта недвижимости"
create table estate_type
(
    type_id   bigint primary key,
    type_name character varying(255)
);


-- Таблица "Объект недвижимости"
create table real_estate
(
    estate_id          bigint primary key,
    district_id        bigint references districts (district_id),
    address            character varying(255),
    floor              bigint,
    room_count         bigint,
    type_id            bigint references estate_type (type_id),
    status             bigint, -- (1 = в продаже, 0 = продана)
    price_per_sqm      double precision,
    estate_description text,
    area               double precision,
    listing_date       timestamp
);

-- Таблица "Критерии оценки"
create table evaluation_criteria
(
    criteria_id   bigint primary key,
    criteria_name character varying(255)
);

-- Таблица "Оценки"
create table evaluations
(
    evaluation_id    bigint primary key,
    estate_id        bigint references real_estate (estate_id),
    evaluation_date  timestamp,
    criteria_id      bigint references evaluation_criteria (criteria_id),
    evaluation_value double precision
);

-- Таблица "Риэлтор"
create table realtors
(
    realtor_id    bigint primary key,
    last_name     character varying(255),
    first_name    character varying(255),
    patronymic    character varying(255),
    contact_phone character varying(20)
);

-- Таблица "Продажа"
create table sales
(
    sale_id    bigint primary key,
    estate_id  bigint references real_estate (estate_id),
    sale_date  timestamp,
    realtor_id bigint references realtors (realtor_id),
    sale_price double precision
);

alter table housing.real_estate
    add constraint fk_district
        foreign key (district_id) references housing.districts (district_id);

alter table housing.real_estate
    add constraint fk_estate_type
        foreign key (type_id) references housing.estate_type (type_id);

alter table housing.sales
    add constraint fk_realtor
        foreign key (realtor_id) references housing.realtors (realtor_id);

alter table housing.sales
    add constraint fk_estate
        foreign key (estate_id) references housing.real_estate (estate_id);

alter table housing.evaluations
    add constraint fk_criteria
        foreign key (criteria_id) references housing.evaluation_criteria (criteria_id);

alter table housing.property_structure
    add constraint fk_property
        foreign key (property_id) references housing.real_estate (estate_id);


-- Заполнение таблицы "Районы"
insert into districts (district_id, district_name)
values (1, 'Центральный'),
       (2, 'Северный'),
       (3, 'Южный'),
       (4, 'Западный'),
       (5, 'Восточный');

-- Заполнение таблицы "Тип объекта недвижимости"
insert into estate_type (type_id, type_name)
values (1, 'Квартира'),
       (2, 'Дом'),
       (3, 'Офис'),
       (4, 'Склад'),
       (5, 'Магазин');

-- Генерация данных для таблицы "Объект недвижимости"
do
$$
    begin
        for i in 1..1000
            loop
                insert into real_estate (estate_id, district_id, address, floor, room_count, type_id, status,
                                         price_per_sqm, estate_description, area, listing_date)
                values (i,
                        (select district_id from districts order by random() limit 1), -- случайный район
                        'Адрес ' || i,
                        (random() * 20)::int, -- случайный этаж от 0 до 20
                        (random() * 5)::int + 1, -- случайное количество комнат от 1 до 5
                        (select type_id from estate_type order by random() limit 1), -- случайный тип
                        (random() * 2)::int, -- статус (0 или 1)
                        (random() * 200000)::numeric(10, 2) + 50000, -- случайная стоимость м² от 50 000 до 250 000
                        'Описание объекта ' || i,
                        (random() * 100)::numeric(5, 2) + 20, -- случайная площадь от 20 до 120 м²
                        now() -
                        (random() * 1000)::int * interval '1 day' -- случайная дата объявления за последние 1000 дней
                       );
            end loop;
    end
$$;

-- Генерация данных для таблицы "Критерии оценки"
insert into evaluation_criteria (criteria_id, criteria_name)
values (1, 'Площадь'),
       (2, 'Местоположение'),
       (3, 'Состояние'),
       (4, 'Цена'),
       (5, 'Инфраструктура');

-- Генерация данных для таблицы "Оценки"
do
$$
    begin
        for i in 1..1000
            loop
                insert into evaluations (evaluation_id, estate_id, evaluation_date, criteria_id, evaluation_value)
                values (i,
                        (select estate_id from real_estate order by random() limit 1), -- случайный объект недвижимости
                        now() -
                        (random() * 1000)::int * interval '1 day', -- случайная дата оценки за последние 1000 дней
                        (select criteria_id from evaluation_criteria order by random() limit 1), -- случайный критерий
                        (random() * 9.99)::numeric(3, 2) -- случайная оценка от 0 до 9.99
                       );
            end loop;
    end
$$;

-- Генерация данных для таблицы "Риэлтор"
do
$$
    begin
        for i in 1..100
            loop
                insert into realtors (realtor_id, last_name, first_name, patronymic, contact_phone)
                values (i,
                        'Фамилия ' || i,
                        'Имя ' || i,
                        'Отчество ' || i,
                        '890000000' || (random() * 9000 + 1000)::int -- случайный номер телефона
                       );
            end loop;
    end
$$;

-- Генерация данных для таблицы "Продажа"
do
$$
    begin
        for i in 1..500
            loop
                insert into sales (sale_id, estate_id, sale_date, realtor_id, sale_price)
                values (i,
                        (select estate_id from real_estate order by random() limit 1), -- случайный объект недвижимости
                        now() -
                        (random() * 1000)::int * interval '1 day', -- случайная дата продажи за последние 1000 дней
                        (select realtor_id from realtors order by random() limit 1), -- случайный риэлтор
                        (random() * 500000)::numeric(10, 2) +
                        1000000 -- случайная стоимость продажи от 1 000 000 до 1 500 000
                       );
            end loop;
    end
$$;


-- Создание схем
create schema if not exists transport;
create schema if not exists housing;

-- Перемещение таблиц для транспортной схемы
alter table country
    set schema transport;
alter table city
    set schema transport;
alter table route
    set schema transport;
alter table flight
    set schema transport;
alter table intermediate_stations
    set schema transport;
alter table ticket
    set schema transport;
alter table bonuses
    set schema transport;
alter table estate_type
    set schema transport;
alter table physical_person
    set schema transport;
alter table ticket_purchase
    set schema transport;

-- Перемещение таблиц для схемы жилья
alter table districts
    set schema housing;
alter table real_estate
    set schema housing;
alter table evaluation_criteria
    set schema housing;
alter table evaluations
    set schema housing;
alter table realtors
    set schema housing;
alter table sales
    set schema housing;