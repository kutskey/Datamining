#get the urls of the 20 minutes homepage
url <- "https://www.20min.ch/"
read_html(url) %>%
  html_elements(css = "a") %>%
  html_attr("href")

#load data
load("data_original/s3-subset.Rdata")

#inspect
view(dat)
str(dat)

#extract column ten
dat[[, 10]]

#these are changes made on github
