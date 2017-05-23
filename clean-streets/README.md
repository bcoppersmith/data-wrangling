# Clean Streets and Trash Cans
This bash script will:

1. download "Clean Streets" and "LA City Receptacles" datasets from Los Angeles's open data portal
2. import both datasets into PostGIS tables
3. count the number of trashcans within ~20 meters of each road in the Clean Streets dataset and populate that into a new table
4. export basic summary statistics

Tested on Mac OS X with PostgreSQL 9.6.3 and PostGIS 2.3.2.
