# Data Mining in R
# University of Lucerne
# 27 April 2024
# Dr. Andrea De Angelis



# Global Health Observatory - WHO
# https://www.who.int/data/gho/info/gho-odata-api
library(tidyverse)
library(httr)
library(rvest)

# Get the list with all the variables that are available (indicators)
#  https://www.who.int/data/gho/data/indicators
response <-  httr::GET(
  url = 'https://ghoapi.azureedge.net/api/Indicator',
  verbose()
)

cnt <- content(response, as = "parsed")
dat <- tibble(
  code = map_chr(cnt$value, 1), 
  name = map_chr(cnt$value, 2), 
  language = map_chr(cnt$value, 3) 
)


# Download data from one indicator (Alcohol consumption per capita): 
dat[dat$code == "SA_0000001400",]
response <-  httr::GET(
  url = 'https://ghoapi.azureedge.net/api/SA_0000001400',
  verbose()
)
cnt_alc <- content(response, as = "parse")
dat <- tibble(
  id = map_chr(cnt_alc$value, 1),         # Extracts the first element (`Id`) from all the 47789 lists inside the cnt$value list
  country = map_chr(cnt_alc$value, 4),    # Extracts the 4th element (`SpatialDim`, country acronym) 
  year = map_dbl(cnt_alc$value, ~(.x)$TimeDim),       # Extracts the year by name 
  value = map_dbl(cnt_alc$value, ~(.x)$NumericValue), 
  continent = map_chr(cnt_alc$value, ~(.x)$ParentLocationCode), 
)

# PLotting alcohol consumption over time:
ggplot(dat, aes(x = year, y = value)) + 
  geom_smooth(aes(group = country), size = 0.1, se = FALSE, color = "black") + 
  geom_smooth(size = 2)

ggplot(dat, aes(x = year, y = value)) + 
  geom_smooth(aes(group = country), size = 0.1, se = FALSE, color = "black") + 
  geom_smooth(aes(color = continent), size = 1.5) + 
  facet_wrap(~continent)
