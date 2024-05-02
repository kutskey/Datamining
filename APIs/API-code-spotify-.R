# Data Mining in R
# University of Lucerne
# 27.04.2024
# Dr. Andrea De Angelis

# TAPPING APIs Spotify:
# The task is to tap the Spotify API to get data about the top 200 Spotify
# songs (here: https://spotifycharts.com/regional/global/weekly/latest). 
# We will use two different API endpoints: 
#     1. The "Tracks" endpoint: https://api.spotify.com/v1/tracks/{id} 
#         which offers data about Spotify tracks; 
#         https://developer.spotify.com/documentation/web-api/reference/#/operations/get-track
#     2. The "Features" endpoint:  

# Sequence of the API tapping task:
# 1. Understand authentication;
# 2. Scrape 200 Spotify songs' codes from the weekly latest chart;
# 3. Tap into Track API to get songs info;
# 4. Tap into Features API to get songs' features;
# 5. Wrangle data & plot


# 1. Authentication -------------------------------------------------------

# Create the developers' app: https://developer.spotify.com/
# Read documentation: https://developer.spotify.com/documentation/web-api/

# Name of the app: "spotifyR"
# Client ID: ***
# Client secret: ***

# Note: I placed my personal password in a csv file
#       so that it can be .gitignored...
spotify_cred <- readr::read_csv(file = here::here("session11-spotify-credentials.csv"))

library(tidyverse)
library(httr)
library(rvest)

clientID <- spotify_cred$clientID
secret <-  spotify_cred$secret

# Autentication process:
# https://developer.spotify.com/documentation/general/guides/authorization-guide/
# There are four different ways, I picked the "Client Credentials":
# https://developer.spotify.com/documentation/general/guides/authorization/client-credentials/
# Instructions: Request authorization
# "The first step is to send a POST request to the /api/token endpoint of the
# Spotify OAuth 2.0 Service with the following parameters...

# This is where I got the endpoint and the fact that I needed a POST request:
# https://developer.spotify.com/documentation/general/guides/authorization/code-flow/

response <-  httr::POST(
  url = 'https://accounts.spotify.com/api/token',
  accept_json(),
#  authenticate(user = clientID, password = secret),    # This would also be OK.
  body = list(grant_type = 'client_credentials',        # This is required, check doc
              client_id = clientID,                     # Credentials
              client_secret = secret, 
              content_type = "application/x-www-form-urlencoded"),   
  encode = 'form',
  verbose()
)

# Extract content from the call and get access token as described in the docs:
content <- httr::content(response)
token <- content$access_token

# We got the token. Next in "Use access token", I read:
# https://developer.spotify.com/documentation/general/guides/authorization/use-access-token/
# Authorization: (Required) 
# Valid access token following the format: Bearer <Access Token>
authorization_header <- str_c(content$token_type, content$access_token, sep = " ")


# Get Spotify categories for Switzerland  -------------------------------------
# https://developer.spotify.com/documentation/web-api/reference/get-categories

# Set up the endpoint and parameters
url_cats <- "https://api.spotify.com/v1/browse/categories"
params <- list(
  country = "CH",
  limit = 10
)

# Make the GET request
response <- GET(url_cats, 
                query = params, 
                add_headers("Authorization" = authorization_header))

# Process the response
cats <- content(response, as = "parsed", encoding = "UTF-8")

# We got the name, the id and the url of the genres:

# name (e.g., first one)
cats[[1]]$items[[1]]$name  # name
cats[[1]]$items[[1]]$id    # id
cats[[1]]$items[[1]]$href  # url

# Let's create a data frame `categories` extracting all the genres:
ids <- names <- hrefs <- vector(mode = "character", length = 10)
for (i in 1:10) {
  ids[i] <- cats[[1]]$items[[i]]$id
  names[i] <- cats[[1]]$items[[i]]$name
  hrefs[i] <- cats[[1]]$items[[i]]$href
}
categories <- tibble(names = names, hrefs = hrefs, id = ids)
categories


# Getting the available playlists for a certain category (e.g., Rock) ---------------
# https://developer.spotify.com/documentation/web-api/reference/get-a-categories-playlists

# endpoints: "https://api.spotify.com/v1/browse/categories/{category_id}/playlists"

# Get the category id:
categories$id[categories$names=="Rock"] # 0JQ5DAqbMKFDXXwE9BDJAr
# categories %>% filter(names=="Rock") %>% select(id) %>% as.character()   # Same thing in dplyr

url_rock <- str_c("https://api.spotify.com/v1/browse/categories/", categories$id[categories$names=="Rock"],"/playlists")
params <- list(
  country = "CH",
  limit = 10
)

# Make the GET request
rock_r <- GET(url_rock, query = params, add_headers("Authorization" = authorization_header))
rock <- content(rock_r, as = "parsed", encoding = "UTF-8")

# Get one playlist:
rock$playlists$items[[1]]$name
rock$playlists$items[[1]]$id

# Collect songs from Rock playlists   ------------------------------------------------
# https://developer.spotify.com/documentation/web-api/reference/get-playlist
url_plls <- str_c("https://api.spotify.com/v1/playlists/", rock$playlists$items[[1]]$id)
plls_r <- GET(url_plls, query = params, add_headers("Authorization" = authorization_header))
plls <- content(plls_r, as = "parsed", encoding = "UTF-8")

# Get songs IDs:
id = plls$tracks$items[[1]]$track$id

# To be continued...

