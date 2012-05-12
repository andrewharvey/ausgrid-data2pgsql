# Author: Andrew Harvey <andrew.harvey4@gmail.com>
# License: CC0 http://creativecommons.org/publicdomain/zero/1.0/
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

download : download-clean download-run
db : db-clean db-load
export : clean-export-csv export-csv

all : download db create-views export-csv
clean : download-clean db-clean clean-export-csv

download-clean :
	rm -rf data

download-run :
	./download-data.sh

db-clean :
	psql -c "DROP SCHEMA IF EXISTS ausgrid CASCADE;"

db-load :
	psql -f create-schema.sql
	./load-works.pl data/works/*.csv
	./load-usage.pl data/usage/*.csv
	psql -c "VACUUM ANALYZE ausgrid.works;"
	psql -c "VACUUM ANALYZE ausgrid.usage;"

create-views :
	psql -f view-asgs-lga.sql
	psql -f view-asgs-exports.sql

clean-export-csv :
	rm -rf export

export-csv :
	mkdir -p export
	psql --no-align --field-separator=',' -c "SELECT * FROM ausgrid.works_asgs_code;" | head  --lines=-1 > export/works-asgs-code.csv
	psql --no-align --field-separator=',' -c "SELECT * FROM ausgrid.usage_asgs_code;" | head  --lines=-1 > export/usage-asgs-code.csv
