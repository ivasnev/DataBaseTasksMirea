-- 1
select car_type         as "Тип вагона",
       count(ticket.id) as "Количество свободных мест"
from ticket
         join flight f on ticket.flight_id = f.id
         join route r on f.route_id = r.id
where train_number = 'A123'
  and departure_datetime = '2024-09-15 08:00:00.000000'
  and status = 1
group by car_type;

-- 2
select c.name              as "Пункт отправления",
       count(train_number) as "Количество поездов"
from route
         join city c on c.id = route.departure_city_id
         join flight f on route.id = f.route_id
where departure_datetime::date = '2024-09-15'
group by c.name;

-- 3
select car_type         as "Тип вагона",
       count(ticket.id) as "Количество вагонов"
from ticket
         join flight f on f.id = ticket.flight_id
         join route r on r.id = f.route_id
where train_number = 'A123'
  and departure_datetime::date = '2024-09-15'
group by car_type;

-- 4
select train_number as "Номера поездов"
from route
         join flight f on route.id = f.route_id
         join ticket t on f.id = t.flight_id
where departure_datetime::date = '2024-09-15'
  and t.car_type = 1
  and t.status = 1
group by train_number
having count(t.id) < 10;

-- 5
select car_type   as "Тип вагона",
       avg(price) as "Средняя цена"
from ticket
         join flight f on ticket.flight_id = f.id
         join route r on r.id = f.route_id
         join city c_a on c_a.id = r.arrival_city_id
         join city c_d on c_d.id = r.departure_city_id
where departure_datetime::date = '2024-09-15'
  and c_d.name = 'Москва'
  and c_a.name = 'Санкт-Петербург'
group by ticket.car_type;

-- 6
select car_type         as "Тип вагона",
       count(ticket.id) as "Количество свободных нижних мест"
from ticket
         join flight f on ticket.flight_id = f.id
         join route r on r.id = f.route_id
where train_number = 'A123'
  and departure_datetime::date = '2024-09-15'
  and status = 1
  and seat_number % 2 = 1
group by car_type;

-- 7
select train_number      as "Номер поезда",
       min(ticket.price) as "Минимальная стоимость",
       arrival_datetime  as "Дата прибытия"
from ticket
         join flight f on ticket.flight_id = f.id
         join route r on r.id = f.route_id
         join intermediate_stations i on f.id = i.flight_id
         join city c on i.city_id = c.id
where c.name = 'Новосибирск'
  and departure_timestamp:: date
      between '2024-09-10' and '2024-09-21'
  and arrival_timestamp:: date
      between '2024-09-10' and '2024-09-21'
group by train_number, arrival_datetime;

-- 8
select car_number   as "Номер Вагона",
       car_type     as "Тип Вагона",
       train_number as "Номер поезда",
       max(price)   as "Максимальная стоимость",
       min(price)   as "Минимальная стоимость"
from ticket
         join flight f on f.id = ticket.flight_id
         join route r on r.id = f.route_id
where train_number = 'A123'
  and status = 1
group by train_number, car_number, car_type
having count(ticket.id) > 1;

-- 9
select t.seat_number / 4 + 1        as "Номер купе",
       count(t.seat_number % 2 = 1) as "Количество свободных нижних мест",
       count(t.seat_number % 2 = 0) as "Количество свободных верхних мест"
from ticket t
         join flight f on f.id = t.flight_id
         join route r on r.id = f.route_id
where t.status = 1
  and t.car_type = 2
  and t.car_number = 4
  and r.train_number = 'A123'
group by "Номер купе";


