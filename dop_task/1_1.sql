-- Создание таблицы Work_Day
create table work_day
(
    employee_id         int,       -- Код сотрудника
    entry_exit_datetime timestamp, -- Дата и время входа/выхода
    reader_value        int,       -- Значение считывателя карты (1 - вход, 2 - выход)
    primary key (employee_id, entry_exit_datetime)
);

-- Вставка тестовых данных
-- INSERT INTO Work_Day (employee_id, entry_exit_datetime, reader_value) VALUES
-- (100, '2023-03-13 09:00:00', 1),
-- (100, '2023-03-13 13:00:00', 2),
-- (100, '2023-03-13 14:00:00', 1),
-- (100, '2023-03-13 18:00:00', 2),
-- (101, '2023-03-13 09:10:00', 1),
-- (101, '2023-03-13 12:42:12', 2),
-- (101, '2023-03-13 13:08:00', 1),
-- (101, '2023-03-13 18:00:00', 2),
-- (102, '2023-03-13 09:00:14', 1),
-- (102, '2023-03-13 13:00:00', 2),
-- (102, '2023-03-13 14:00:00', 1),
-- (102, '2023-03-13 19:30:10', 2);

do
$$
    declare
        emp_id           int; -- Код сотрудника
        curr_date        date; -- Текущая дата
        entry_time       time; -- Время входа
        lunch_start_time time; -- Время начала обеда
        lunch_end_time   time; -- Время конца обеда
        exit_time        time; -- Время выхода
    begin
        -- Цикл по сотрудникам
        for emp_id in 100..120
            loop
                -- Цикл по датам
                for curr_date in
                    select generate_series(date '2023-03-13', date '2023-04-19', interval '1 day')::date
                    loop
                        -- Генерация случайных времён
                        entry_time := time '09:00:00' + make_interval(secs => floor(random() * 60 * 30));
                        lunch_start_time := time '13:00:00' + make_interval(secs => floor(random() * 60 * 30));
                        lunch_end_time := time '14:00:00' + make_interval(secs => floor(random() * 60 * 30));
                        exit_time := time '18:00:00' + make_interval(secs => floor(random() * 60 * 30));

                        -- Вставка данных в таблицу
                        insert into work_day (employee_id, entry_exit_datetime, reader_value)
                        values (emp_id, curr_date + entry_time, 1),       -- Вход
                               (emp_id, curr_date + lunch_start_time, 2), -- Уход на обед
                               (emp_id, curr_date + lunch_end_time, 1),   -- Возвращение с обеда
                               (emp_id, curr_date + exit_time, 2); -- Выход
                    end loop;
            end loop;
    end
$$;

create or replace function calculate_weekly_hours(employee_id int, week_start date, week_end date)
    returns text as
$$
declare
    total_hours          interval := interval '0 hours';
    work_start           timestamp;
    work_end             timestamp;
    total_hours_in_hours numeric;
begin
    -- Цикл по всем входам/выходам за неделю
    for work_start, work_end in
        select pd.work_start, pd.work_end
        from (select entry_exit_datetime                                                   as work_start,
                     lead(entry_exit_datetime)
                     over (partition by work_day.employee_id order by entry_exit_datetime) as work_end,
                     reader_value
              from work_day
              where work_day.employee_id = calculate_weekly_hours.employee_id
                and entry_exit_datetime::date between week_start and week_end) as pd
        where pd.reader_value = 1
        loop
            -- Суммируем разницу времени между входом и следующим выходом
            if work_end is not null then
                total_hours := total_hours + (work_end - work_start);
            end if;
        end loop;

    -- Преобразуем общее количество часов в числовой формат
    total_hours_in_hours := extract(epoch from total_hours) / 3600;

    -- Сравнение общего времени с нормой и вывод результата
    if total_hours_in_hours < 40 then
        return 'Меньше нормы, общее время: ' || total_hours_in_hours || ' часов';
    elsif total_hours_in_hours = 40 then
        return 'Норма, общее время: 40 часов';
    else
        return 'Больше нормы, общее время: ' || total_hours_in_hours || ' часов';
    end if;
end;
$$ language plpgsql;

select calculate_weekly_hours(102, '2023-03-13'::date, '2023-03-17'::date);

INSERT INTO work_day (employee_id, entry_exit_datetime, reader_value)
VALUES
    -- Понедельник
    (1, '2023-03-13 08:00:00', 1),
    (1, '2023-03-13 13:10:00', 2),
    (1, '2023-03-13 13:50:00', 1),
    (1, '2023-03-13 19:00:00', 2),
    -- Вторник
    (1, '2023-03-14 08:00:00', 1),
    (1, '2023-03-14 13:10:00', 2),
    (1, '2023-03-14 13:50:00', 1),
    (1, '2023-03-14 19:00:00', 2),
    -- Среда
    (1, '2023-03-15 08:00:00', 1),
    (1, '2023-03-15 13:10:00', 2),
    (1, '2023-03-15 13:50:00', 1),
    (1, '2023-03-15 19:00:00', 2),
    -- Четверг
    (1, '2023-03-16 08:00:00', 1),
    (1, '2023-03-16 13:10:00', 2),
    (1, '2023-03-16 13:50:00', 1),
    (1, '2023-03-16 19:00:00', 2),
    -- Пятница
    (1, '2023-03-17 08:00:00', 1),
    (1, '2023-03-17 13:10:00', 2),
    (1, '2023-03-17 13:50:00', 1),
    (1, '2023-03-17 19:00:00', 2);


create or replace function calculate_salary(
    employee_id int,
    base_salary numeric,
    week_start date,
    week_end date
)
    returns numeric as
$$
declare
    total_late_minutes   int     := 0;
    penalty_factor       numeric := 1.0;
    salary               numeric;
    work_start           timestamp;
    work_end             timestamp;
    work_date            date;
    lunch_start          timestamp;
    lunch_end            timestamp;
    expected_work_start  timestamp;
    expected_work_end    timestamp;
    expected_lunch_start timestamp;
    expected_lunch_end   timestamp;
begin
    -- Вычисление штрафного коэффициента
    for work_date, work_start, work_end, lunch_start, lunch_end in
        (with daily_events as (select work_day.employee_id,
                                      entry_exit_datetime::date                                                                        as work_date,
                                      entry_exit_datetime,
                                      reader_value,
                                      lead(entry_exit_datetime)
                                      over (partition by work_day.employee_id, entry_exit_datetime::date order by entry_exit_datetime) as next_event,
                                      lead(reader_value)
                                      over (partition by work_day.employee_id, entry_exit_datetime::date order by entry_exit_datetime) as next_reader_value
                               from work_day
                               where work_day.employee_id = calculate_salary.employee_id
                                 and entry_exit_datetime::date between week_start and week_end),
              work_segments as (select de.employee_id,
                                       de.work_date,
                                       min(entry_exit_datetime) filter (where reader_value = 1)                  as work_start,
                                       min(entry_exit_datetime)
                                       filter (where reader_value = 2 and next_reader_value = 1)                 as lunch_start,
                                       max(next_event) filter (where reader_value = 2 and next_reader_value = 1) as lunch_end,
                                       max(entry_exit_datetime) filter (where reader_value = 2)                  as work_end
                                from daily_events as de
                                group by de.employee_id, de.work_date)

         select ws.work_date,
                ws.work_start,
                ws.work_end,
                ws.lunch_start,
                ws.lunch_end

         from work_segments as ws)
        loop
            raise notice '_____________________________________________________________________________';
            raise notice 'Начало работы: %, Конец работы: %, Начало ланча: %, Конец ланча: %', work_start, work_end, lunch_start, lunch_end;
            -- Ожидаемое начало и конец рабочего дня
            expected_work_start := work_date + interval '9 hours';
            expected_work_end := work_date + interval '18 hours';

            -- Ожидаемое время обеда
            expected_lunch_start := work_date + interval '13 hours';
            expected_lunch_end := work_date + interval '14 hours';

            -- Проверка времени начала рабочего дня
            if work_start > expected_work_start then
                raise notice 'Начало работы: %, Ожидаемое начало: %, Штрафные минуты: %', work_start, expected_work_start,
                        extract(epoch from (work_start - expected_work_start)) / 60;
                total_late_minutes := total_late_minutes + extract(epoch from (work_start - expected_work_start)) / 60;
            end if;

            -- Проверка времени окончания рабочего дня
            if work_end < expected_work_end then
                raise notice 'Конец работы: %, Ожидаемый конец: %, Штрафные минуты: %', work_end, expected_work_end,
                        extract(epoch from (expected_work_end - work_end)) / 60;
                total_late_minutes := total_late_minutes + extract(epoch from (expected_work_end - work_end)) / 60;
            end if;

            if lunch_start < expected_lunch_start then
                raise notice 'Начало ланча: %, Ожидаемое начало: %, Штрафные минуты: %', lunch_start, expected_lunch_start,
                        extract(epoch from (expected_lunch_start - lunch_start)) / 60;
                total_late_minutes :=
                            total_late_minutes + extract(epoch from (expected_lunch_start - lunch_start)) / 60;
            end if;

            if lunch_end > expected_lunch_end then
                raise notice 'Конец ланча: %, Ожидаемый конец: %, Штрафные минуты: %', lunch_end, expected_lunch_end,
                        extract(epoch from (lunch_end - expected_lunch_end)) / 60;
                total_late_minutes := total_late_minutes + extract(epoch from (lunch_end - expected_lunch_end)) / 60;
            end if;
        end loop;


    raise notice 'Итоговое время штрафа за период: %', total_late_minutes;
    -- Цикл по каждому рабочему дню
    penalty_factor := greatest(0.0, 1.0 - (total_late_minutes / 10) * 0.05);
    -- Расчет зарплаты
    salary := base_salary + (base_salary * penalty_factor);
    return salary;
end;
$$ language plpgsql;


select * from calculate_salary(1, 50000, '2023-03-13', '2023-03-17');



