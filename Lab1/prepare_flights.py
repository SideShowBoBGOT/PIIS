import os

os.system('head -n 100000 ../../flights.csv > data/raw_flights.csv')

with open('data/flights.csv', 'w') as out_file:
    out_file.writelines(['year,month,day,day_of_week,fl_date,carrier,tail_num,fl_num,origin,dest,crs_dep_time,dep_time,dep_delay,taxi_out,wheels_off,wheels_on,taxi_in,crs_arr_time,arr_time,arr_delay,cancelled,cancellation_code,diverted,crs_elapsed_time,actual_elapsed_time,air_time,distance,carrier_delay,weather_delay,nas_delay,security_delay,late_aircraft_delay\n'])
    with open('data/raw_flights.csv', 'r') as in_file:
        for line in in_file.readlines():
            out_file.writelines([line[:-2] + '\n'])

os.system('rm data/raw_flights.csv')