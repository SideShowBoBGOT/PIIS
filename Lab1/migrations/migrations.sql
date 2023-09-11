CREATE DATABASE mopr_lab_1_column;

CREATE TABLE IF NOT EXISTS airlines (
    id SERIAL PRIMARY KEY,
    iata_code VARCHAR(2) DEFAULT NULL,
    airline VARCHAR(30) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS airports (
    id SERIAL PRIMARY KEY,
    iata_code VARCHAR(3) DEFAULT NULL,
    airport VARCHAR(80) DEFAULT NULL,
    city VARCHAR(30) DEFAULT NULL,
    state VARCHAR(2) DEFAULT NULL,
    country VARCHAR(30) DEFAULT NULL,
    latitude DECIMAL(11,4) DEFAULT NULL,
    longitude DECIMAL(11,4) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS flights (
    id SERIAL PRIMARY KEY,
    year INTEGER DEFAULT NULL,
    month INTEGER DEFAULT NULL,
    day INTEGER DEFAULT NULL,
    day_of_week INTEGER DEFAULT NULL,
    fl_date DATE DEFAULT NULL,
    carrier VARCHAR(2) DEFAULT NULL,
    tail_num VARCHAR(6) DEFAULT NULL,
    fl_num INTEGER DEFAULT NULL,
    origin VARCHAR(5) DEFAULT NULL,
    dest VARCHAR(5) DEFAULT NULL,
    crs_dep_time VARCHAR(4) DEFAULT NULL,
    dep_time VARCHAR(4) DEFAULT NULL,
    dep_delay DECIMAL(13,2) DEFAULT NULL,
    taxi_out DECIMAL(13,2) DEFAULT NULL,
    wheels_off VARCHAR(4) DEFAULT NULL,
    wheels_on VARCHAR(4) DEFAULT NULL,
    taxi_in DECIMAL(13,2) DEFAULT NULL,
    crs_arr_time VARCHAR(4) DEFAULT NULL,
    arr_time VARCHAR(4) DEFAULT NULL,
    arr_delay DECIMAL(13,2) DEFAULT NULL,
    cancelled DECIMAL(13,2) DEFAULT NULL,
    cancellation_code VARCHAR(20) DEFAULT NULL,
    diverted DECIMAL(13,2) DEFAULT NULL,
    crs_elapsed_time DECIMAL(13,2) DEFAULT NULL,
    actual_elapsed_time DECIMAL(13,2) DEFAULT NULL,
    air_time DECIMAL(13,2) DEFAULT NULL,
    distance DECIMAL(13,2) DEFAULT NULL,
    carrier_delay DECIMAL(13,2) DEFAULT NULL,
    weather_delay DECIMAL(13,2) DEFAULT NULL,
    nas_delay DECIMAL(13,2) DEFAULT NULL,
    security_delay DECIMAL(13,2) DEFAULT NULL,
    late_aircraft_delay DECIMAL(13,2) DEFAULT NULL
);

COPY airlines(iata_code, airline) FROM '/docker-entrypoint-initdb.d/airlines.csv' DELIMITER ',' CSV HEADER;
COPY airports(iata_code, airport, city, state, country, latitude, longitude) FROM '/docker-entrypoint-initdb.d/airports.csv' DELIMITER ',' CSV HEADER;
COPY flights(year, month, day, day_of_week, fl_date, carrier, tail_num, fl_num, origin, dest, crs_dep_time, dep_time, dep_delay, taxi_out, wheels_off, wheels_on, taxi_in, crs_arr_time, arr_time, arr_delay, cancelled, cancellation_code, diverted, crs_elapsed_time, actual_elapsed_time, air_time, distance, carrier_delay, weather_delay, nas_delay, security_delay, late_aircraft_delay) FROM '/docker-entrypoint-initdb.d/flights.csv' DELIMITER ',' CSV HEADER;

