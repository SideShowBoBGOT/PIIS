/*regular*/
select a.city as city, SUM(f.late_aircraft_delay) as total_delay from flights as f
inner join airports as a on a.iata_code = f.dest
group by city;

select a.city as city, SUM(f.id) as total_flights from flights as f
inner join airports as a on a.iata_code = f.dest
group by city;

with t as (
    select a.city as city, SUM(f.late_aircraft_delay) as total_delay from flights as f
    inner join airports as a on a.iata_code = f.dest
    group by city
)
select city, total_delay from t where total_delay = (SELECT MIN(total_delay) from t LIMIT 1);

with t as (
    select a.city as city, SUM(f.late_aircraft_delay) as total_delay from flights as f
    inner join airports as a on a.iata_code = f.dest
    group by city
)
select city, total_delay from t where total_delay = (SELECT MAX(total_delay) from t LIMIT 1);

select f.id from flights as f
where f.id > (SELECT PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY flights.late_aircraft_delay) FROM flights);

/*columnar*/