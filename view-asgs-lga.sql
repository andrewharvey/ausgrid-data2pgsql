CREATE OR REPLACE VIEW ausgrid.asgs_2011_nsw_lga AS (
  SELECT
    l.code as asgs_code,
    l.name as asgs_name,
    asgs_2011.shorten_lga_name(l.name) as short_name,
    s.name as state
  FROM asgs_2011.lga l
  JOIN asgs_2011.ste s ON l.ste = s.code
  WHERE (s.name = 'New South Wales'));
