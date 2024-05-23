DROP SCHEMA IF EXISTS reporting CASCADE;
CREATE SCHEMA reporting;

CREATE OR REPLACE VIEW reporting.flight AS
SELECT 
    *,
    CASE 
        WHEN dep_delay_new > 0 THEN 1
        ELSE 0 
    END AS is_delayed
FROM
    public.flight
WHERE
    cancelled = 0;


CREATE OR REPLACE VIEW reporting.top_reliability_roads AS
SELECT
    rf.origin_airport_id,
    al1.name AS origin_airport_name,
    rf.dest_airport_id,
    al2.name AS dest_airport_name,
    rf.year,
    COUNT(*) AS cnt,
    ROUND(AVG(rf.is_delayed)::numeric, 2) AS reliability,
    RANK() OVER (ORDER BY ROUND(AVG(rf.is_delayed)::numeric, 2) DESC) AS nb
FROM
    reporting.flight rf
JOIN
    airport_list al1 ON rf.origin_airport_id = al1.origin_airport_id
JOIN
    airport_list al2 ON rf.dest_airport_id = al2.origin_airport_id
GROUP BY
    rf.origin_airport_id,
    al1.name,
    rf.dest_airport_id,
    al2.name,
    rf.year
HAVING
    COUNT(*) > 10000
ORDER BY
    reliability DESC
LIMIT 10;


CREATE OR REPLACE VIEW reporting.year_to_year_comparision AS
SELECT
    year,
    month,
    COUNT(*) AS flights_amount,
    ROUND(AVG(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END)::numeric, 2) AS reliability
FROM
    public.flight
GROUP BY
    year,
    month
ORDER BY
    year,
    month;


CREATE OR REPLACE VIEW reporting.day_to_day_comparision AS
SELECT
    year,
    day_of_week,
    COUNT(*) AS flights_amount, 
    ROUND(AVG(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END)::numeric, 2) AS reliability  
FROM
    reporting.flight  
GROUP BY
    year, day_of_week
ORDER BY
    year, day_of_week;


CREATE OR REPLACE VIEW reporting.day_by_day_reliability AS
SELECT
    TO_DATE(year || '-' || LPAD(month::text, 2, '0') || '-' || LPAD(day_of_month::text, 2, '0'), 'YYYY-MM-DD') AS date,
    ROUND(AVG(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END)::numeric, 2) AS reliability
FROM
    reporting.flight  
GROUP BY
    year, month, day_of_month
ORDER BY
    date;

