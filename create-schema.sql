-- Author: Andrew Harvey <andrew.harvey4@gmail.com>
-- License: CC0 http://creativecommons.org/publicdomain/zero/1.0/
--
-- To the extent possible under law, the person who associated CC0
-- with this work has waived all copyright and related or neighboring
-- rights to this work.
-- http://creativecommons.org/publicdomain/zero/1.0/

-- This schema is partially derived from the source data schema.
-- http://www.ausgrid.com.au/Common/About-us/Sharing-information/Data-to-share.aspx
-- The source webpage states "There are no restrictions on the data we share."

CREATE SCHEMA ausgrid;

CREATE DOMAIN ausgrid.hour AS NUMERIC(4, 1);

CREATE DOMAIN ausgrid.month AS smallint
CHECK (
  VALUE >= 1 AND VALUE <= 12
);

CREATE DOMAIN ausgrid.year AS smallint;

CREATE TABLE ausgrid.works
(
  lga_name text,
  time_period_start_month ausgrid.month,
  time_period_end_month ausgrid.month,
  time_period_year ausgrid.year,
  repairs integer,
  average_repair_time ausgrid.hour,
  proactive_replacement integer,
  total_use bigint,
  average_daily_use ausgrid.hour,
  new_small_substations integer,
  installing_cables integer,
  maintenance_jobs integer,
  connections integer,
  generation_capacity integer,
  exported_power integer,
  reports integer,
  clean_ups integer,
  average_response_time ausgrid.hour,
  PRIMARY KEY (lga_name, time_period_start_month, time_period_end_month, time_period_year)
);

-- For a given ASGS LGA name return a ausgrid.network_info LGA short version of the name
CREATE OR REPLACE FUNCTION ausgrid.shorten_lga_name(name text) RETURNS text AS $$
BEGIN
  return regexp_replace(name, ' Shire.*', '', 'i');
END
$$ LANGUAGE plpgsql;


CREATE TABLE ausgrid.usage
(
  year ausgrid.year,
  lga_name text,
  residential_general_supply_kwh bigint,
  residential_general_supply_customers integer,
  residential_off_peak_hot_water_kwh  bigint,
  residential_off_peak_hot_water_customers integer,
  non_residential_small_kwh bigint,
  non_residential_small_customers integer,
  non_residential_medium_large_kwh bigint,
  non_residential_medium_large_customers integer,
  PRIMARY KEY (year, lga_name)
);
