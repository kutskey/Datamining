library(nycflights13)
View(flights)
View(planes)


#join planes to flights
library(tidyverse)
?left_join

flightswithplane <- left_join(flights,planes,by = "tailnum")
view(flightswithplane)
flightswithplane

#as an experiment join flights to planes
planewithflights <- right_join(flights,planes,by = "tailnum")
view(planewithflights)

#check for missing planes in the flights dataset
length(unique(x = flightswithplane$tailnum)) - 
  length(unique(planes$tailnum))

#plot seats with delay
ggplot(data = flightswithplane, aes(x = seats, y= arr_delay)) +
  geom_point() +
  geom_smooth()

#save the plot to the subfolder plots
ggsave("plots/seats_vs_delay.png")



