CREATE TABLE object_description (
    object_id SERIAL PRIMARY KEY,
    description JSONB NOT NULL
);

CREATE TABLE real_estate_objects
(
    object_id    bigint NOT NULL
        PRIMARY KEY,
    address      varchar(255),
    floor        bigint,
    room_count   bigint,
    type_id      bigint,
    price        double precision,
    owner        text,
    area         double precision,
    listing_date timestamp
);

INSERT INTO real_estate_objects (object_id, address, floor, room_count, type_id, price, owner, area, listing_date)
VALUES
(1, 'Московская область, г.Москва, Тверской район, ул.Тверская, д.12, кв.34', 5, 3, 1, 120000.00, 'Иван', 60.0, '2024-12-01 10:00:00'),
(2, 'Санкт-Петербург, г.Санкт-Петербург, Центральный район, ул.Нева, д.45, кв.10', 3, 2, 2, 85000.00, 'Владимир', 45.0, '2024-12-02 12:00:00'),
(3, 'Московская область, г.Пушкино, Пушкинский район, ул.Лесная, д.8, кв.4', 2, 1, 3, 45000.00, null, 30.0, '2024-12-03 14:00:00'),
(4, 'Новосибирская область, г.Новосибирск, Центральный район, ул.Ленина, д.123, кв.45', 9, 4, 1, 160000.00, 'Кирилл', 85.0, '2024-12-04 15:30:00'),
(5, 'Краснодарский край, г.Краснодар, Западный район, ул.Красная, д.88, кв.12', 7, 2, 2, 95000.00, 'Антон', 50.0, '2024-12-05 16:45:00'),
(6, 'Челябинская область, г.Челябинск, Калининский район, ул.Комсомольская, д.10, кв.3', 1, 3, 1, 115000.00, 'Игнат', 70.0, '2024-12-06 17:30:00'),
(7, 'Республика Татарстан, г.Казань, Вахитовский район, ул.Ленина, д.78, кв.25', 4, 2, 3, 105000.00, 'Станислав', 55.0, '2024-12-07 18:00:00'),
(8, 'Калужская область, г.Калуга, Центральный район, ул.Щербинки, д.54, кв.2', 6, 1, 2, 50000.00, 'Анна', 35.0, '2024-12-08 19:00:00'),
(9, 'Воронежская область, г.Воронеж, Советский район, ул.Школьная, д.23, кв.6', 4, 3, 1, 130000.00, 'Светлана', 75.0, '2024-12-09 20:15:00'),
(10, 'Ростовская область, г.Ростов-на-Дону, Железнодорожный район, ул.Северная, д.10, кв.8', 8, 2, 3, 105000.00, 'Алена', 60.0, '2024-12-10 21:30:00'),
(11, 'Москва, г.Москва, Тверской район, ул.Тверская, д.24, кв.11', 4, 2, 1, 95000.00, 'Ирина', 55.0, '2024-12-11 10:00:00'),
(12, 'Москва, г.Москва, Тверской район, ул.Тверская, д.30, кв.8', 6, 3, 1, 125000.00, 'Олег', 70.0, '2024-12-12 11:15:00'),
(13, 'Москва, г.Москва, Арбатский район, ул.Арбат, д.15, кв.22', 3, 2, 1, 115000.00, 'Владислав', 50.0, '2024-12-13 12:30:00'),
(14, 'Москва, г.Москва, Арбатский район, ул.Арбат, д.23, кв.5', 7, 1, 2, 85000.00, 'Вадим', 40.0, '2024-12-14 13:00:00'),
(15, 'Москва, г.Москва, Тверской район, ул.Тверская, д.18, кв.10', 3, 3, 1, 110000.00, 'Артем', 65.0, '2024-12-15 14:45:00');




INSERT INTO object_description (object_id, description)
SELECT object_id,
       JSONB_BUILD_OBJECT(
               'Price', price,
               'Rooms', room_count,
               'Owner', COALESCE(owner, 'Нет данных'),
               'Floor', floor,
               'ListingDate', listing_date,
               'Area', JSONB_BUILD_ARRAY(area, area * 0.8),
               'Address', JSONB_BUILD_OBJECT(
                       'Region', TRIM(SPLIT_PART(address, ',', 1)),
                       'City', TRIM(SPLIT_PART(address, ',', 2)),
                       'District', TRIM(SPLIT_PART(address, ',', 3)),
                       'Street', TRIM(SPLIT_PART(address, ',', 4)),
                       'HouseNumber', TRIM(SPLIT_PART(address, ',', 5)),
                       'ApartmentNumber', CASE
                                              WHEN type_id = 1 THEN 'Нет'
                                              ELSE TRIM(SPLIT_PART(address, ',', 6))
                           END
                   )
           )
FROM real_estate_objects;


-- 1 адреса двухкомнатных объектов недвижимости в указанном районе
SELECT
    (description->'Address'->>'Street')::varchar || ' ' ||
    (description->'Address'->>'HouseNumber')::varchar  ||  ' ' ||
    (description->'Address'->>'ApartmentNumber')::varchar AS Address
FROM
    object_description
WHERE
    (description->>'Rooms')::int = 2
    AND description->'Address'->>'District' = 'Центральный район';

-- 2 Вывести разницу в процентах между общей и жилой площадью для каждого объекта недвижимости
SELECT object_id,
       (((description -> 'Area' ->> 0)::float - (description -> 'Area' ->> 1)::float) /
        (description -> 'Area' ->> 0)::float) * 100
           AS area_difference_percent
FROM object_description
WHERE description -> 'Area' ->> 0 IS NOT NULL
  AND description -> 'Area' ->> 1 IS NOT NULL;

-- 3 Вывести стоимость 1м² для объектов недвижимости, расположенных на указанном этаже
SELECT object_id,
       ROUND(((description ->> 'Price')::int / (description -> 'Area' ->> 0)::float)) AS price_per_sqm
FROM object_description
WHERE (description ->> 'Floor')::int = 5;

-- 4 Подсчитать количество объектов недвижимости по каждому городу, городу и району, общее количество.
-- В итоговых строках NULL значения заменить на соответствующий текст в зависимости от уровней группировки.
SELECT
    COALESCE(description->'Address'->>'City', 'Не указан город') AS city,
    COALESCE(description->'Address'->>'District', 'Не указан район') AS district,
    COUNT(object_id) AS object_count
FROM object_description
GROUP BY city, district
ORDER BY city, district;

-- 5 Подсчитать среднюю площадь объектов недвижимости по каждому городу и району.
SELECT
    COALESCE(description->'Address'->>'City', 'Не указан город') AS city,
    COALESCE(description->'Address'->>'District', 'Не указан район') AS district,
    AVG((description->'Area'->>0)::float) AS avg_area
FROM object_description
GROUP BY city, district
ORDER BY city, district;

-- 6 Определить максимальную и минимальную стоимость по области, области и району
SELECT
    COALESCE(description->'Address'->>'Region', 'Не указана область') AS region,
    COALESCE(description->'Address'->>'City', 'Не указан город') AS city,
    COALESCE(description->'Address'->>'District', 'Не указан район') AS district,
    MAX((description->>'Price')::float) AS max_price,
    MIN((description->>'Price')::float) AS min_price
FROM object_description
GROUP BY region, city, district
ORDER BY region, city, district;

-- 7 Вывести список объектов недвижимости и отклонение от средней стоимости по району,
-- где располагается данный объект недвижимости.
WITH avg_price_per_district AS (
    SELECT
        description->'Address'->>'District' AS district,
        ROUND(AVG((description->>'Price')::float)) AS avg_price
    FROM object_description
    GROUP BY district
)
SELECT
    o.object_id,
    o.description->'Address'->>'City' AS city,
    o.description->'Address'->>'District' AS district,
    o.description->>'Price' AS price,
    apd.avg_price,
    ((o.description->>'Price')::float - apd.avg_price) AS price_deviation
FROM object_description o
JOIN avg_price_per_district apd
    ON apd.district = o.description->'Address'->>'District'
ORDER BY o.object_id;

-- 8 Вывести полный адрес объектов недвижимости, которые были проданы в текущем году.
SELECT o.object_id,
       (o.description -> 'Address' ->> 'Region')::varchar || ', ' ||
       (o.description -> 'Address' ->> 'City')::varchar || ', ' ||
       (o.description -> 'Address' ->> 'Street')::varchar || ', д.' ||
       (o.description -> 'Address' ->> 'HouseNumber')::varchar || ', кв.' ||
       (o.description -> 'Address' ->> 'ApartmentNumber')::varchar AS full_address
FROM object_description o
WHERE EXTRACT(YEAR FROM (o.description ->> 'ListingDate')::timestamp) = EXTRACT(YEAR FROM CURRENT_DATE)
ORDER BY o.object_id;