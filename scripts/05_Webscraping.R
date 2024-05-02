# clear the environment
rm(list = ls())

#check the working directory
getwd()

#load the libraries
library(tidyverse)
library(rvest)

### scrape Watson ####

#scrape article titles of the watson website (use Selector Gadget in Chrome)
css_selector <- ".pr-2.font-bold"
read_html("https://www.watson.ch/") %>%
  html_elements(css = css_selector) %>%
  html_text()

# get the links
links <- read_html("https://www.watson.ch/") %>%
  html_elements(css = "a" ) %>%
  html_attr("href")

#drop links to other subpages
links <- links[119:300]

#create empty container
articles <- vector(mode = "list", length = length(links))

#scrape the articles
for (i in 1:length(links)) {
  articles[i] <- read_html(links[i]) %>%
    html_elements(css = "p") %>%
    html_text()
  Sys.sleep(2) 
}

#stop executing code here
stop()