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
