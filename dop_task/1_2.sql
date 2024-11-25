create or replace function calculate_hourly_employee_count(work_date date)
returns table (
    "interval" varchar,
    employees_count int
) as
$$
with daily_events as (select work_day.employee_id,
                                      entry_exit_datetime as start_w,
                                      reader_value,
                                      lead(entry_exit_datetime)
                                      over (partition by work_day.employee_id, entry_exit_datetime::date order by entry_exit_datetime) as end_w
                               from work_day where entry_exit_datetime::date = work_date),
 intervals as (
    select start_w as interval_start, end_w as interval_end  from daily_events where reader_value = 1
),
hourly_intervals as (
    select
        case
            when generate_series = date_trunc('hour', interval_start) then interval_start
            else generate_series
        end as hour_start,
        case
            when generate_series + '59 minutes 59 seconds'::interval > interval_end then interval_end
            else generate_series + '59 minutes 59 seconds'::interval
        end as hour_end
    from (
        select generate_series(
            date_trunc('hour', interval_start),
            interval_end,
            '1 hour'::interval
        ) as generate_series,
            intervals.*
        from intervals
    ) series
),
    base_interval as (
        select (generate_series('2023-01-01 00:00:00'::timestamp, '2023-01-01 23:00:00'::timestamp, '1 hour'::interval))::time as hour_start,
    ((generate_series('2023-01-01 23:59:59'::timestamp, '2023-01-02 22:59:59'::timestamp, '1 hour'::interval)) + '1 hour'::interval)::time as hour_end
)
select
    (base_interval.hour_start || '-' || base_interval.hour_end) as "interval",
    COALESCE(count(hourly_intervals.*), 0) as employees_count
from base_interval
left join hourly_intervals
    on base_interval.hour_start = hourly_intervals.hour_start::time
    and base_interval.hour_end = hourly_intervals.hour_end::time
group by base_interval.hour_start, base_interval.hour_end
order by "interval";
$$ language sql;

select * from calculate_hourly_employee_count('2023-03-18');

