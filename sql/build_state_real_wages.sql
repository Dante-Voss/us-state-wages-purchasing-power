-- build_state_real_wages.sql
-- Purpose: Construct state-level real wages adjusted by RPP
-- Inputs:
--   state_rpp_metro_nonmetro
--   state_urban_share
--   state_wage_job
--   employment_per_1000_raw
-- Output:
--   state_wage_job_real_final
-- Notes:
--   RPP indexed to US = 100
--   Farmers excluded due to missing employment data

select *
from occupation_state_salary
select *
from employment_per_1000_raw
select *
from state_rpp_metro_nonmetro
select *
from state_urban_share

-- changing code now
drop table if exists state_true_rpp;

create table state_true_rpp as
with rpp_parsed as (
  select
    split_part(geoname, ' (', 1) as state,
    case
      when geoname like '%(Metropolitan Portion)%' then 'metro'
      when geoname like '%(Nonmetropolitan Portion)%' then 'nonmetro'
      else 'other'
    end as portion,
    rpp
  from state_rpp_metro_nonmetro
),
rpp_pivot as (
  select
    state,
    max(case when portion = 'metro' then rpp end) as metro_rpp,
    max(case when portion = 'nonmetro' then rpp end) as nonmetro_rpp
  from rpp_parsed
  where portion in ('metro','nonmetro')
  group by state
)
select
  p.state,
  round(u.urban_share / 100.0, 2) as urban_share,
  round(
    p.metro_rpp * (u.urban_share / 100.0)
    + p.nonmetro_rpp * (1 - u.urban_share / 100.0),
    2
  ) as true_state_rpp
from rpp_pivot p
join state_urban_share u
  on p.state = u.state;

create index if not exists idx_state_true_rpp_state
  on state_true_rpp(state);

select *
from state_true_rpp

drop table if exists state_wage_job_with_rpp;

create table state_wage_job_with_rpp as
select
  w.*,
  r.true_state_rpp
from occupation_state_salary w
left join state_true_rpp r
  on w.state = r.state;

create index if not exists idx_state_wage_job_with_rpp_state
  on state_wage_job_with_rpp(state);
select *
from state_wage_job_with_rpp

drop table if exists state_wage_job_real;

create table state_wage_job_real as
select
  *,
  round(median_annual_wage * (100.0 / true_state_rpp), 2) as real_median_annual_wage
from state_wage_job_with_rpp
where true_state_rpp is not null;

create index if not exists idx_state_wage_job_real_state
  on state_wage_job_real(state);

select state, occupation, median_annual_wage, true_state_rpp, real_median_annual_wage
from state_wage_job_real
order by real_median_annual_wage desc
limit 10;

drop table if exists state_wage_job_real_clean;

create table state_wage_job_real_clean as
select
  state,
  occupation,
  median_annual_wage,
  true_state_rpp,
  round(median_annual_wage * (100.0 / true_state_rpp), 2) as real_median_annual_wage
from state_wage_job_with_rpp
where median_annual_wage is not null
  and true_state_rpp is not null;

select
  state,
  occupation,
  median_annual_wage,
  true_state_rpp,
  real_median_annual_wage
from state_wage_job_real_clean
order by median_annual_wage desc
limit 10;

select
  state,
  occupation,
  median_annual_wage,
  true_state_rpp,
  real_median_annual_wage
from state_wage_job_real_clean
order by real_median_annual_wage desc
limit 10;

drop table if exists state_wage_job_real_with_emp;

create table state_wage_job_real_with_emp as
with emp as (
  select
    split_part(area_name, ' (', 1) as state,
    occupation,
    case
      when regexp_replace(employment_per_1000, '[^0-9\.]', '', 'g') = ''
        then null
      else regexp_replace(employment_per_1000, '[^0-9\.]', '', 'g')::numeric
    end as employment_per_1000
  from employment_per_1000_raw
)
select
  w.*,
  e.employment_per_1000
from state_wage_job_real_clean w
left join emp e
  on w.state = e.state
 and w.occupation = e.occupation;

create index if not exists idx_state_wage_job_real_with_emp_state_occ
  on state_wage_job_real_with_emp(state, occupation);

select
  state,
  occupation
from state_wage_job_real_with_emp
where employment_per_1000 is null
order by state, occupation;

drop table if exists state_wage_job_real_final;

create table state_wage_job_real_final as
select *
from state_wage_job_real_with_emp
where occupation <> 'Farmer';

select * 
from state_wage_job_real_final

