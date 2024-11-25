-- 1
select city_dep.name as "Город А", city_arr.name as "Город Б", f.departure_datetime, f.arrival_datetime
from flight f
         join route r on f.route_id = r.id
         join city city_dep on r.departure_city_id = city_dep.id
         join city city_arr on r.arrival_city_id = city_arr.id
where city_dep.name = 'Москва'
  and city_arr.name = 'Санкт-Петербург';
-- 2
select city.name as "Промежуточная станция", i_s.departure_timestamp, i_s.arrival_timestamp
from intermediate_stations i_s
         join flight f on i_s.flight_id = f.id
         join route r on f.route_id = r.id
         join city on i_s.city_id = city.id
where r.train_number = 'A123'
  and f.departure_datetime = '2024-09-15 08:00:00.000000'
order by i_s.departure_timestamp;

-- 3
select r.train_number, city_dep.name as "Пункт отправления"
from intermediate_stations i_s
         join flight f on i_s.flight_id = f.id
         join route r on f.route_id = r.id
         join city city_dep on r.departure_city_id = city_dep.id
where i_s.city_id = (select id from city where name = 'Екатеринбург')
  and i_s.departure_timestamp = '2024-09-16 11:00:00.000000';

--4
select distinct t.car_type, city_dep.name
from ticket t
         join flight f on t.flight_id = f.id
         join route r on f.route_id = r.id
         join city city_dep on r.departure_city_id = city_dep.id
where r.train_number = 'A123'
  and f.departure_datetime = '2024-09-15 08:00:00.000000'
order by city_dep.name;
--5
select count(*) as "Количество свободных мест"
from ticket t
         join flight f on t.flight_id = f.id
         join route r on f.route_id = r.id
where r.train_number = 'A123'
  and f.departure_datetime = '2024-09-15 08:00:00.000000'
  and t.status = 1;
--6
select avg(t.price) as "Средняя стоимость"
from ticket t
         join flight f on t.flight_id = f.id
         join route r on f.route_id = r.id
         join city city_dep on r.departure_city_id = city_dep.id
         join city city_arr on r.arrival_city_id = city_arr.id
where city_dep.name = 'Москва'
  and city_arr.name = 'Санкт-Петербург'
  and t.car_type = 2::bigint;
--7
select max(t.price) as "Самая дорогая стоимость"
from ticket t
         join flight f on t.flight_id = f.id
where f.departure_datetime = '2024-09-15 08:00:00.000000';
--8
select count(*) as "Количество свободных нижних мест"
from ticket t
         join flight f on t.flight_id = f.id
         join route r on f.route_id = r.id
where r.train_number = 'A123'
  and f.departure_datetime = '2024-09-15 08:00:00.000000'
  and t.car_type = 1::bigint
  and t.seat_number % 2 = 1
  and t.status = 1;
--9
select t.price        as "Минимальная стоимость билета",
       r.train_number as "Номер поезда",
       city_dep.name  as "Пункт отправления",
       city_arr.name  as "Пункт прибытия"
from intermediate_stations as i_s
         join city c on c.id = i_s.city_id
         join flight f on f.id = i_s.flight_id
         join ticket t on f.id = t.flight_id
         join route r on r.id = f.route_id
         join city city_dep on r.departure_city_id = city_dep.id
         join city city_arr on r.arrival_city_id = city_arr.id
where c.name = 'Екатеринбург'
  and i_s.departure_timestamp::date = '2024-09-16'
  and car_type = 2::bigint
order by price
limit 1;

--10
select r.train_number, f.departure_datetime
from intermediate_stations i_s
         join flight f on i_s.flight_id = f.id
         join route r on f.route_id = r.id
where i_s.city_id = (select id from city where name = 'Екатеринбург')
  and f.departure_datetime between now() and now() + interval '90 days'
order by f.departure_datetime;
