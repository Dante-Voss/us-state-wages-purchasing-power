--table creation
create table occupation_state_salary (
state text,
median_annual_wage numeric,
occupation text
);

create table state_rpp_metro_nonmetro (
geoname text,
rpp numeric
)

create table state_urban_share(
state text,
urban_share numeric
)

CREATE TABLE employment_per_1000_raw (
    area_name TEXT,
    employment_per_1000 TEXT,
    occupation TEXT
);
