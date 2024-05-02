#load data
load("data_orig/stream.json")

#inspect
view(dat)
str(dat)

#extract column ten
dat[, "deep_list..Not.yet"]

# change default working directory
setwd("C:\Users\sile9\OneDrive\Desktop")
getwd()


#clear environment
rm(list=ls())

#strings with stringr
library(stringr)

#Encoding
charToRaw("Hello world!")
Sys.getlocale()

#Escaping
obj <- "hesitating then no longer, \"Sir,\" said I"
obj
str_replace_all(obj, "\"", "")
cat(obj)

#Regular expressions
x <- c("apple", "banana", "pear", "pineapple")
str_view_all(x, pattern = "^p")

y <- c("1a", "2b", "3c", "4d")
str_view_all(y, "\\d")


# Create a vector of numbers
numbers <- c(1, 2, 3, 4, 5)

# Loop through each element in the vector
for (i in numbers) {
  print(i)
}



