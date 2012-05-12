-- Create views of original tables plus ASGS LGA code
CREATE OR REPLACE VIEW ausgrid.works_asgs_code AS (
  SELECT lga.asgs_code, b.*
  FROM ausgrid.asgs_2011_nsw_lga lga
  JOIN ausgrid.works b ON ausgrid.shorten_lga_name(lga.short_name) = b.lga_name);

CREATE OR REPLACE VIEW ausgrid.usage_asgs_code AS (
  SELECT lga.asgs_code, b.*
  FROM ausgrid.asgs_2011_nsw_lga lga
  JOIN ausgrid.usage b ON lower(ausgrid.shorten_lga_name(lga.short_name)) = lower(b.lga_name));

