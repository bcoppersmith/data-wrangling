#!/bin/bash
set -e

DATABASE=city_data
CLEAN_STREETS_TABLE=clean_streets
RECEPTACLES_TABLE=receptacles
CANS_PER_ROAD_TABLE=cans_per_road

CLEAN_STREETS=http://geohub.lacity.org/datasets/674e3757160f4901a11cc56c2386929d_0.geojson
RECEPTACLES=http://geohub.lacity.org/datasets/b998c1a838b4471cb486bb150b2684d9_0.geojson

cat << EOF
====================================
Creating DB and PostGIS extension
====================================
EOF
createdb -U $USER $DATABASE
psql -U $USER -d $DATABASE -c 'CREATE EXTENSION postgis'

cat << EOF
====================================
Loading clean streets table into PG
====================================
EOF
curl $CLEAN_STREETS | ogr2ogr -f "PostgreSQL" PG:"dbname=$DATABASE user=${USER}" -nln $CLEAN_STREETS_TABLE /vsistdin/

cat << EOF
====================================
Loading receptacles table into PG
====================================
EOF
curl $RECEPTACLES | ogr2ogr -f "PostgreSQL" PG:"dbname=$DATABASE user=${USER}" -nln $RECEPTACLES_TABLE /vsistdin/

cat << EOF
====================================
Exporting data
====================================
EOF
psql -U $USER -d $DATABASE << PG
  CREATE FUNCTION nearby_receptacles(geometry) RETURNS bigint AS \$\$
    SELECT count(*) FROM $RECEPTACLES_TABLE WHERE ST_DWithin($RECEPTACLES_TABLE.wkb_geometry, \$1, 0.0002);
  \$\$ LANGUAGE SQL;

  CREATE TABLE $CANS_PER_ROAD_TABLE AS (
    SELECT ogc_fid,
      fullname,
      lapd_grid,
      min_from_l,
      code,
      gattedalley,
      cs_roundscore,
      cd,
      sandist,
      illegalseg,
      bulkysegsc,
      llitterseg,
      wdssegsc,
      shape__length,
      wkb_geometry,
      nearby_receptacles(wkb_geometry),
      (nearby_receptacles(wkb_geometry) / shape__length) AS cans_per_meter
    FROM $CLEAN_STREETS_TABLE);

  COPY (
    SELECT
      cs_roundscore,
      count(cs_roundscore),
      avg(nearby_receptacles) AS avg_cans,
      avg(cans_per_meter) AS avg_ratio
    FROM $CANS_PER_ROAD_TABLE
    GROUP BY cs_roundscore)
  TO '$PWD/roundscore_scores.csv' WITH CSV DELIMITER ',' HEADER;

  COPY (
    SELECT
      llitterseg,
      count(llitterseg),
      avg(nearby_receptacles) AS avg_cans,
      avg(cans_per_meter) AS avg_ratio
    FROM $CANS_PER_ROAD_TABLE
    GROUP BY llitterseg)
  TO '$PWD/litterseg_scores.csv' WITH CSV DELIMITER ',' HEADER;
PG
