# Billboard Hot 100 Top 10 Stats Collection

## Source data
Collect basic information on every Billboard Hot 100 Top 10 song since 1958.

Finds songs from pages like this: https://en.wikipedia.org/wiki/List_of_Billboard_Hot_100_top_10_singles_in_2002

Retrieves producer and artist information from pages like these: https://en.wikipedia.org/wiki/A_Woman%27s_Worth

Usage:
``` bash
ruby lib/top_10_singles_generator.rb
```

## Parse Data
Find top producers and artsists, by year, from the above data.

Usage:
``` bash
cat [DATA INPUT FILE] | ruby stats.rb
```
