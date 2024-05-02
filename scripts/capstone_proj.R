#load packages
library(jsonlite)

#read the json file
data <- fromJSON("data_orig/swiss_voting.json")
data2 <- fromJSON("data_orig/us_voting.json")

#parse the json
str(data)
str(data2)

#convert the json to a dataframe
df <- as.data.frame(data)
df2 <- as.data.frame(data2)

#check if the variables are the same
names(df)
names(df2)
