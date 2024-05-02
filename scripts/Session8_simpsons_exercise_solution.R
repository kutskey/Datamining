# Data Mining in R
# University of Lucerne
# 26 April 2024
# Dr. Andrea De Angelis

# Your Turn - The Simpsons exercise  ---------------------------------
library(rvest)
library(tidyverse)

# Head to: "https://www.imdb.com/title/tt0096697". 
# The page contains information about all The Simpson's episodes. 
browseURL("https://www.imdb.com/title/tt0096697")


# 1. Inspect the page. 
# Inspecting the page I note that the links to the other seasons and episodes
# are on this page. I also note a lot of JavaScript code (non HTML). I can
# search for words I see to find out the location in the code.

# 2. Get the titles of the episodes from the season 32. 
# When I click the link to season 32 I see that the URL changes to:
# "https://www.imdb.com/title/tt0096697/episodes?season=32". So I can use the
# "episodes?season=**" field in the URL to navigate the seasons.

# I use SelectorGadget to only select the titles, and the CSS selector I get is
# "#episodes_content strong a".

download.file(url = "https://www.imdb.com/title/tt0096697/episodes?season=32", 
              destfile = here::here("season_32.html"))

# Downloading file more politely:
require(httr)

# Create a function `download_politely(from_url, to_html)` to download politely
# the web page:
download_politely <- function(from_url, to_html, my_email, my_agent = R.Version()$version.string) {
  
  require(httr)

  # Check that arguments are of the expected type:
  stopifnot(is.character(from_url))
  stopifnot(is.character(to_html))
  stopifnot(is.character(my_email))
  
  # GET politely
  simps_req <- httr::GET(url = from_url, 
                         add_headers(
                           From = my_email,   # Provides email to let webmaster get in touch
                           `User-Agent` = R.Version()$version.string     # Adds infos about our software
                         )
  )
  # If status == 200, extract content and save to a file:
  if (httr::http_status(simps_req)$message == "Success: (200) OK") {
    bin <- content(simps_req, as = "raw")
    writeBin(object = bin, con = to_html)
  } else {
    # Else, print a message to understand that we have a problem
    cat("Houston, we have a problem!")
  }
}

# Call the customized function:
download_politely(from_url = "https://www.imdb.com/title/tt0096697/episodes?season=32", 
                  to_html = here::here("season_32_polite.html"), 
                  my_email = "sile97@windowslive.com")

# Extract the titles:
read_html(here::here("season_32_polite.html")) %>% 
  html_elements(css = ".ipc-title-link-wrapper") %>% 
  html_text(trim = TRUE)

# In case we needed the links...
read_html(here::here("season_32_polite.html")) %>% 
  html_elements(css = ".ipc-title-link-wrapper") %>% 
  html_attr(name = "href")


# 3. Now get the titles of the episodes from all the seasons.

# If I click on Season 31 I note that the URL becomes: 
# https://www.imdb.com/title/tt0096697/episodes?season=31
# So I can build a vector with the URLs from season 1 to 31, and then use it to
# scrape all the titles.

# Build the full list of links to each season:
require(stringr)
links <- str_c("https://www.imdb.com/title/tt0096697/episodes?season=", 1:31)
dir.create("simpsons")   # Create a new folder where to store all the files

# Loop over the link for each season:
for (i in seq_along(links)) {
  cat(i, " ")
  
  download_politely(from_url = links[i], 
                    to_html = here::here("simpsons", str_c("season_",i,".html")), 
                    my_email = "my@email.com")
  
  Sys.sleep(2)
}

# Now I need to scrape the titles from the page of each season
to_scrape <- list.files(here::here("simpsons"), full.names = TRUE)   # get the list of pages for the seasons
all_episodes <- vector(mode = "list", length = length(to_scrape))    # empty container where to place the titles

# Loop over the pages of each season and scrape the titles
for (i in seq_along(all_episodes)){
  all_episodes[[i]] <- read_html(to_scrape[i]) %>% 
    html_elements(css = ".ipc-title-link-wrapper") %>% 
    html_text(trim = TRUE)
}

str(all_episodes)
all_episodes[[1]]    # Episodes from season 1
all_episodes[[2]]    # Episodes from season 2...
