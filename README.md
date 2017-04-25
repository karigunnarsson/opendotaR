## What the package does

Package to simplify using opendota.com's API, get game lists, and download JSON's of parsed replays 
from the opendota API. Also has functionality to execute own code to extract the specific parts of 
the JSON file. This has no direct relation to opendota.com, i'm just a guy that likes playing with
their data and needed a neat wrapper to fetch it more efficiently :)

## How to use the package

There are two basic ways of using the package, either to get the total JSON for each replay, which
is the simple way of doing it as it requires no changes, the other way is to create your own .R file
that reads the JSON (variable read_json) and selects specific parts of it to output.

### Simple version
To get the full JSON output, just put a list of match_id's (in numeric vector form) into get_games(),
to get a list of games, you can use get_game_list(). Note that only about 5% of matches are parsed,
and higher num_open_profile (number of players in game with an open profile) will increase your
percentage of parsed matches.

```R
game_list <- get_game_list(num_matches = 100,
                           from_time = "20170401",
                           to_time = "20170425",
                           min_mmr = 3000,
                           num_open_profile = 6)

match_id_vec <- game_list$match_id

parsed_games <- get_games(match_id_vec)
```

Output will be a list, each list item will be the JSON from a parsed replay.

### More complex version
Each parsed mach is read into a read_json variable in the R function environment, and then output to
output_list if output = "all", if however you specify an R file destination in output, for example
output = "test.R", it will source that R file for each parsed game.

That means you will have to create some output and make sure it gets assigned to output_list like so

```R
output_list[[parsed_count]] <- your_output
```

You will also need to load all libraries needed inside the R, file, here is an example that outputs
the hero_id, and number of wards bought in the game. I save the file as test.R

```R
library(jsonlite)
library(data.table)

ward_list <- list()

# Iterate through each player, getting the values we need.
for(j in 1:10) {
  # Total number of wards bought the first 20 minutes
  purchase_log <- as.data.frame(read_json$players$purchase_log[j])
  
  if (nrow(purchase_log) > 0) {
    wards_only <- subset(purchase_log, 
                         (purchase_log$key == "ward_sentry" | purchase_log$key == "ward_observer"))
    
    if (nrow(wards_only) > 0) {
      wards_bought <- data.frame(hero = read_json$players$hero_id[j],
                                 wards_bought = nrow(wards_only))
    } else {
      wards_bought <- data.frame(hero = read_json$players$hero_id[j],
                                 wards_bought = 0)
    }
  } else {
    wards_bought <- data.frame(hero = read_json$players$hero_id[j],
                               wards_bought = 0)
  }
  
  ward_list[[j]] <- wards_bought
}

output_list[[parsed_count]] <- rbindlist(ward_list, fill = TRUE)

```

If you know just call get_games() the same way as before, but using output = "test.R" (or whereever
you've stored the R file), you will get list output with the total number of wards bought by each 
hero in all games parsed.

```R
game_list <- get_game_list(num_matches = 100,
                           from_time = "20170401",
                           to_time = "20170425",
                           min_mmr = 3000,
                           num_open_profile = 6)

match_id_vec <- game_list$match_id

parsed_games <- get_games(match_id_vec, output = "test.R")
```

Note the output here will be a list of multiple data frames, to get it as one large dataframe simply
use rbindlist(parsed_games).

## Installation

The package is not on CRAN, i might try that later, not entirely convinced they'd be thrilled
with the way i wrote the package (source'ing a local R file in the package), so for now i just store
the tarball on my website, [you can download it here](http://www.karigunnarsson.com/wp-content/uploads/2017/04/opendotaR_0.1.2.tar.gz) and manually install it to R if you are interested.

## Issues?

I mostly made the package for myself so i don't expect many to use it, but if do, and you run into 
any issues or have ideas for further features the package should have, feel free to drop me a line 
at kari.gunnarsson@outlook.com or open an issue here on github.
