create table study_schedule
(
    year    integer     not null,
    code    varchar(10) not null,
    course  integer     not null,
    week_1  char,
    week_2  char,
    week_3  char,
    week_4  char,
    week_5  char,
    week_6  char,
    week_7  char,
    week_8  char,
    week_9  char,
    week_10 char,
    week_11 char,
    week_12 char,
    week_13 char,
    week_14 char,
    week_15 char,
    week_16 char,
    week_17 char,
    week_18 char,
    week_19 char,
    week_20 char,
    week_21 char,
    week_22 char,
    week_23 char,
    week_24 char,
    week_25 char,
    week_26 char,
    week_27 char,
    week_28 char,
    week_29 char,
    week_30 char,
    week_31 char,
    week_32 char,
    week_33 char,
    week_34 char,
    week_35 char,
    week_36 char,
    week_37 char,
    week_38 char,
    week_39 char,
    week_40 char,
    week_41 char,
    week_42 char,
    week_43 char,
    week_44 char,
    week_45 char,
    week_46 char,
    week_47 char,
    week_48 char,
    week_49 char,
    week_50 char,
    week_51 char,
    week_52 char,
    primary key (year, code, course)
);

alter table study_schedule
    owner to postgres;

INSERT INTO study_schedule (
    year,
    code,
    course,
    week_1, week_2, week_3, week_4, week_5, week_6, week_7, week_8, week_9, week_10,
    week_11, week_12, week_13, week_14, week_15, week_16, week_17, week_18, week_19, week_20,
    week_21, week_22, week_23, week_24, week_25, week_26, week_27, week_28, week_29, week_30,
    week_31, week_32, week_33, week_34, week_35, week_36, week_37, week_38, week_39, week_40,
    week_41, week_42, week_43, week_44, week_45, week_46, week_47, week_48, week_49, week_50,
    week_51, week_52
) VALUES
-- Курс 1: Теоретическое обучение, экзамены, каникулы и практика
(2024, '090302', 1,
 -- С 1 по 16 неделя - Теоретическое обучение
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 -- С 17 по 22 неделя - Промежуточная аттестация
 'Э', 'Э', 'Э', 'Э', 'Э', 'Э',
 -- С 23 по 24 неделя - Каникулы
 'К', 'К',
 -- С 25 по 40 неделя - Теоретическое обучение
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 -- С 41 по 42 неделя - Промежуточная аттестация
 'Э', 'Э',
 -- С 43 по 44 неделя - Каникулы
 'К', 'К',
 -- С 45 по 48 неделя - Практика
 'П', 'П', 'П', 'П',
 -- С 49 по 52 неделя - Каникулы
 'К', 'К', 'К', 'К'
),
-- Курс 2: Аналогичный шаблон, пример данных
(2024, '090302', 2,
 -- С 1 по 16 неделя - Теоретическое обучение
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 -- С 17 по 22 неделя - Промежуточная аттестация
 'Э', 'Э', 'Э', 'Э', 'Э', 'Э',
 -- С 23 по 24 неделя - Каникулы
 'К', 'К',
 -- С 25 по 40 неделя - Теоретическое обучение
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 'Т', 'Т', 'Т', 'Т', 'Т', 'Т',
 -- С 41 по 42 неделя - Промежуточная аттестация
 'Э', 'Э',
 -- С 43 по 44 неделя - Каникулы
 'К', 'К',
 -- С 45 по 48 неделя - Практика
 'П', 'П', 'П', 'П',
 -- С 49 по 52 неделя - Каникулы
 'К', 'К', 'К', 'К'
);

create or replace function calculate_intervals2(
    start_year int,
    code_inp varchar
)
    returns table (
        course_id      int,
        week_value varchar,
        "interval" varchar
    ) as
$$
declare
    old_course int := 0;
    week_start date;
    week_end date; -- Конечная дата интервала
    week_count int; -- Количество недель в группе
begin
    -- Цикл по группам из CTE
    week_start := DATE_TRUNC('year', TO_DATE(start_year::TEXT, 'YYYY')) + INTERVAL '8 months';
    for course_id, week_value, week_count in
        (with schedule_array as (select year,
                                        code,
                                        course,
                                        array [
                                            week_1, week_2, week_3, week_4, week_5, week_6, week_7, week_8, week_9, week_10,
                                            week_11, week_12, week_13, week_14, week_15, week_16, week_17, week_18, week_19, week_20,
                                            week_21, week_22, week_23, week_24, week_25, week_26, week_27, week_28, week_29, week_30,
                                            week_31, week_32, week_33, week_34, week_35, week_36, week_37, week_38, week_39, week_40,
                                            week_41, week_42, week_43, week_44, week_45, week_46, week_47, week_48, week_49, week_50,
                                            week_51, week_52
                                            ] as week_s
                                 from study_schedule
                                 where year >= start_year and code = code_inp
                                 ),
              indexed_week_s as (select year,
                                        code,
                                        course,
                                        generate_subscripts(week_s, 1)         as week__number, -- Номер недели (индекс массива)
                                        week_s[generate_subscripts(week_s, 1)] as week__value   -- Значение недели
                                 from schedule_array),
              grouped_week_s as (select year,
                                        code,
                                        course,
                                        week__number,
                                        week__value,
                                        case
                                            when week__value =
                                                 lag(week__value)
                                                 over (partition by year, code, course order by week__number)
                                                then 0
                                            else 1
                                            end as is_new_group
                                 from indexed_week_s),
              final_index as (select year,
                                     code,
                                     course,
                                     week__number,
                                     week__value,
                                     sum(is_new_group)
                                     over (partition by year, code, course order by week__number) as group_index
                              from grouped_week_s),
              indexed_rows as (select year,
                                      code,
                                      course,
                                      week__number,
                                      week__value,
                                      group_index
                               from final_index
                               order by year, code, course, week__number),
              grouped_weeks as (select ir.course,
                                       ir.group_index,
                                       ir.week__value,
                                       count(*) as week_count -- Количество недель в группе
                                from indexed_rows ir
                                group by ir.course, ir.group_index, ir.week__value
                                order by ir.course, ir.group_index)
         select gp.course, gp.week__value, gp.week_count
         from grouped_weeks gp)
    loop
        if course_id != old_course then
            week_start := DATE_TRUNC('year', TO_DATE(week_start::TEXT, 'YYYY')) + INTERVAL '8 months'; -- 1 сентября
            IF EXTRACT(DOW FROM week_start) IN (6) THEN
                week_start := week_start + (8 - EXTRACT(DOW FROM week_start))::INT * INTERVAL '1 day';
            END IF;
            IF EXTRACT(DOW FROM week_start) IN (0) THEN
                week_start := week_start + 1 * INTERVAL '1 day';
            END IF;
            old_course := course_id;
        end if;

        -- Вычисление конечной даты интервала
        week_end := week_start + (week_count * 7 - 1);

        -- Заполнение выходных параметров
        "interval" := to_char(week_start, 'YYYY-MM-DD') || ' - ' || to_char(week_end, 'YYYY-MM-DD');
        week_value := CASE week_value
                            WHEN 'Т' THEN 'Theoretical Training'
                            WHEN 'Э' THEN 'Intermediate Assessment'
                            WHEN 'К' THEN 'Holidays'
                            WHEN 'П' THEN 'Practice'
                        END;
        course_id := course_id;

        -- Возврат строки в результирующую таблицу
        return next;

        -- Обновление даты начала недели для следующего интервала
        week_start := week_end + 1;
    end loop;
end;
$$ language plpgsql;

select * from calculate_intervals2(2025, '090302');
