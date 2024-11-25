-- 1 Вывести адреса объектов недвижимости, у которых стоимость 1 м2 меньше средней стоимости по району.
select r.address
from housing.real_estate r
         join housing.districts d on r.district_id = d.district_id
where r.price_per_sqm < (select avg(price_per_sqm)
                         from housing.real_estate
                         where district_id = d.district_id);

-- 2 Вывести название районов, в которых количество проданных квартир больше 5.
select d.district_name, count(s.sale_id)
from real_estate re
         join housing.districts d on re.district_id = d.district_id
         join housing.sales s on d.district_id = s.estate_id
group by d.district_id
having count(s.sale_id) > 5;

-- 3 Вывести адреса квартир и название района, средняя оценка которых выше 3,5 баллов.
select r.address, d.district_name
from housing.real_estate r
         join housing.districts d on r.district_id = d.district_id
         join housing.evaluations e on r.estate_id = e.estate_id
group by r.address, d.district_name
having avg(e.evaluation_value) > 3.5;

-- 4. Определить годы, в которых было размещено от 2 до 3 объектов недвижимости.
select extract(year from listing_date) as year
from housing.real_estate
group by year
having count(estate_id) between 2 and 3;

-- 5. Определить ФИО риэлторов, которые ничего не продали в текущем году.
select concat(r.first_name, ' ', substring(r.last_name, 1, 1), '.') as realtor_full_name
from housing.realtors r
         left join housing.sales s
                   on r.realtor_id = s.realtor_id and extract(year from s.sale_date) = extract(year from current_date)
group by r.realtor_id
having count(s.sale_id) = 0;

-- 6. Определить ФИО риэлторов, продавших квартиры, более чем в двух районах.
select concat(r.first_name, ' ', substring(r.last_name, 1, 1), '.') as realtor_full_name
from housing.realtors r
         join housing.sales s on r.realtor_id = s.realtor_id
         join housing.real_estate re on s.estate_id = re.estate_id
group by r.realtor_id
having count(distinct re.district_id) > 2;

-- 7. Вывести названия районов, в которых средняя площадь продаваемых квартир больше 30 м².
select d.district_name
from housing.districts d
         join housing.real_estate re on d.district_id = re.district_id
         join housing.sales s on re.estate_id = s.estate_id
group by d.district_id
having avg(re.area) > 30;

-- 8. Вывести для указанного риэлтора (ФИО) года, в которых он продал больше 2 объектов недвижимости.
select extract(year from s.sale_date) as sale_year
from housing.sales s
         join housing.realtors r on s.realtor_id = r.realtor_id
where concat(r.last_name, ' ', substring(r.first_name, 1, 1), '.', substring(r.patronymic, 1, 1), '.') =
      'Иванов И.И.'
group by sale_year
having count(s.sale_id) > 2;

-- 9. Вывести ФИО риэлторов, которые заработали премию в текущем месяце больше 40000 рублей.
select concat(r.first_name, ' ', substring(r.last_name, 1, 1), '.') as realtor_full_name
from housing.realtors r
         join housing.sales s on r.realtor_id = s.realtor_id
where extract(month from s.sale_date) = extract(month from current_date)
  and extract(year from s.sale_date) = extract(year from current_date)
group by r.realtor_id
having sum(s.sale_price) * 0.15 > 40000;

-- 10. Вывести количество однокомнатных и двухкомнатных квартир в указанном районе.
select case
           when r.room_count = 1 then 'Однокомнатных квартир'
           when r.room_count = 2 then 'Двухкомнатных квартир'
           else 'Больше двух комнат'
           end  as apartment_type,
       count(*) as property_count
from housing.real_estate r
where r.district_id = (select d.district_id from housing.districts d where d.district_name = 'Восточный')
group by apartment_type
order by apartment_type;

-- 11. Определить среднюю оценку по каждому критерию для указанного объекта недвижимости.
select c.criteria_name         as критерий,
       avg(e.evaluation_value) as средняя_оценка,
       case
           when avg(e.evaluation_value) >= 9.0 then 'превосходно'
           when avg(e.evaluation_value) >= 8.0 then 'очень хорошо'
           when avg(e.evaluation_value) >= 7.0 then 'хорошо'
           when avg(e.evaluation_value) >= 6.0 then 'удовлетворительно'
           else 'неудовлетворительно'
           end                 as текст
from housing.evaluations e
         join housing.evaluation_criteria c on e.criteria_id = c.criteria_id
where e.estate_id = 533
group by c.criteria_id;

-- 12. Добавить новую таблицу «Структура объекта недвижимости».
create table if not exists housing.property_structure
(
    property_id bigint,
    room_type   smallint check (room_type in (1, 2, 3, 4)), -- 1 - кухня, 2 - зал, 3 - спальня, 4 - санузел
    area        double precision check (area > 0),
    foreign key (property_id) references housing.real_estate (estate_id)
);

-- 13. Вывести информацию о комнатах для объекта недвижимости.
select room_type, area
from housing.property_structure
where property_id = 533;

-- 14. Рассчитать какой процент составляет площадь каждого типа комнаты объекта недвижимости от общей площади.
select room_type,
       area,
       (area / (select sum(area) from housing.property_structure where property_id = 533)) * 100 as area_percentage
from housing.property_structure
where property_id = 533;

-- 15. Вывести количество объектов недвижимости по каждому району, общая площадь которых больше 40 м².
select d.district_name, count(*) as property_count
from housing.real_estate r
         join housing.districts d on r.district_id = d.district_id
where r.area > 40
group by d.district_name;

-- 16. Вывести квартиры, которые были проданы не позже 4 месяцев после размещения объявления о их продаже.
select r.address
from housing.real_estate r
         join housing.sales s on r.estate_id = s.estate_id
where s.sale_date <= r.listing_date + interval '4 months';

-- 17. Вывести адреса и статус объектов недвижимости, стоимость 1 м² которых меньше средней всех объектов недвижимости по району.
select r.address, r.status
from housing.real_estate r
where r.price_per_sqm < (select avg(price_per_sqm)
                         from housing.real_estate
                         where district_id = r.district_id)
  and r.listing_date >= now() - interval '4 months';

-- 18. Вывести информацию о количество продаж в предыдущем и текущем годах по каждому району.
select d.district_name,
       count(case
                 when extract(year from s.sale_date) = extract(year from current_date)
                     then 1 end)                                                                                   as current_year_sales,
       count(case
                 when extract(year from s.sale_date) = extract(year from current_date) - 1
                     then 1 end)                                                                                   as previous_year_sales,
       (count(case when extract(year from s.sale_date) = extract(year from current_date) - 1 then 1 end) -
        count(case when extract(year from s.sale_date) = extract(year from current_date) then 1 end)) * 100.0 /
       nullif(count(case when extract(year from s.sale_date) = extract(year from current_date) - 1 then 1 end),
              0)                                                                                                   as percentage_change
from real_estate
         join districts d on real_estate.district_id = d.district_id
         left join housing.sales s on d.district_id = s.estate_id
group by d.district_id;

-- 19. Сформировать статистику по продажам за указанный год.
select et.type_name                                               as property_type,
       count(s.sale_id)                                           as sale_count,
       (count(s.sale_id) * 100.0 / sum(count(s.sale_id)) over ()) as percentage_of_total,
       sum(s.sale_price)                                          as total_sum
from housing.sales s
         join housing.real_estate r on s.estate_id = r.estate_id
         join housing.estate_type et on r.type_id = et.type_id
where extract(year from s.sale_date) = '2022'
group by et.type_id;
