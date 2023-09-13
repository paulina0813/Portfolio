##PREPARE PHASE

#Load Libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
library(dplyr)
library(geosphere)
library(janitor)
library(winch)
library(vctrs)
library(knitr)
library(lessR)
library(kableExtra)
library(ggmap)

#Import data files
jan22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202201-divvy-tripdata.csv')
feb22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202202-divvy-tripdata.csv')
mar22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202203-divvy-tripdata.csv')
apr22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202204-divvy-tripdata.csv')
may22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202205-divvy-tripdata.csv')
jun22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202206-divvy-tripdata.csv')
jul22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202207-divvy-tripdata.csv')
aug22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202208-divvy-tripdata.csv')
sep22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202209-divvy-publictripdata.csv')
oct22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202210-divvy-tripdata.csv')
nov22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202211-divvy-tripdata.csv')
dec22 <- read.csv('/Users/Paulina_1/Documents/Data Analysis Certification Google/Case Studies/Case Study 1 - Cyclistic/Data/202212-divvy-tripdata.csv')

#Check column names for consistency
colnames(jan22)
colnames(feb22)
colnames(mar22)
colnames(apr22)
colnames(may22)
colnames(jun22)
colnames(jul22)
colnames(aug22)
colnames(sep22)
colnames(oct22)
colnames(nov22)
colnames(dec22)

#Check consistency of structures
str(jan22)
str(feb22)
str(mar22)
str(apr22)
str(may22)
str(jun22)
str(jul22)
str(aug22)
str(sep22)
str(oct22)
str(nov22)
str(dec22)

#Combine the individual monthly dataframes into a single dataframe for the entire year
year22 <- bind_rows(jan22, feb22, mar22, apr22, may22, jun22, jul22, aug22, sep22, oct22, nov22, dec22)



##PROCESS PHASE

#Preview the first 5 rows of the df
head(year22)
#Preview the last 6 rows of the df
tail(year22)
#Check names and data type of columns
str(year22)

#Statistical summary of data
summary(year22)

#Check amount or rows
nrow(year22)
#Check column names
colnames(year22)
#Check dimensions of dataframe
dim(year22)
#Check how many different types of rideable_type there are
distinct(year22, rideable_type)
#Check that there are only members and casual riders in the member_casual category
distinct(year22, member_casual)
#Count the amount of trips that correspond to members and casual riders respectively
year22 %>%
  count(member_casual)
#Check how many NAs there are in each column
sapply(year22, function(x) sum(is.na(x)))

#Check if the values missing for end_lat are located in the same rows as the values missing for end_lng
missing_end_lat <- which(is.na(year22$end_lat))
missing_end_lng <- which(is.na(year22$end_lng))
setequal(missing_end_lat, missing_end_lng)

#Check for duplicates in ride_id
duplicates_ride_id <- year22 %>%
  duplicated(year22, ride_id, incomparables = FALSE, fromLast = FALSE)

TRUE %in% duplicates_ride_id

#Convert ended_at and started_at to POSIXct format to represent date-time values
year22$ended_at <- as.POSIXct(year22$ended_at, format = "%Y-%m-%d %H:%M:%S")
year22$started_at <- as.POSIXct(year22$started_at, format = "%Y-%m-%d %H:%M:%S")

#Divide the current datetime format into different columns for date, start time, end time, month, year, and day of the week
year22 <- year22%>%
  mutate(date = format(as.Date(started_at), "%d")) %>% #Extract date
  mutate(start_time = format(started_at, format = "%H:%M:%S")) %>% #Extract start time
  mutate(end_time = format(ended_at, format = "%H:%M:%S")) %>% #Extract end time
  mutate(year = format(as.Date(started_at), "%Y")) %>% #Extract year
  mutate(month = format(as.Date(started_at), "%B")) %>% #Extract month
  mutate(day_of_week = format(as.Date(started_at), "%A")) #Extract day of week

#Convert end_time and #start_time into POSIXct objects so that they represent time values
year22$end_time <- as.POSIXct(year22$end_time, format = "%H:%M:%S")
year22$start_time <- as.POSIXct(year22$start_time, format = "%H:%M:%S")

#Create an additional column that contains the time difference between the end time and the start time in order to determine the duration of the ride in seconds
year22 <- year22%>%
  mutate(ride_length = difftime(end_time, start_time))

#Inspect the structure of added columns
str(year22)

#Convert ride_length to numeric
year22$ride_length <- as.numeric(as.character(year22$ride_length))

#Confirm that the values in the column are numeric
is.numeric(year22$ride_length) 

# Create a filtered dataset with non-NA lat and lng values for the start stations
valid_stations <- year22 %>%
  filter(!is.na(start_lat) & !is.na(start_lng)) %>%
  select(start_station_name, start_lat, start_lng)

# Loop through each row in year22 to find and replace NA values in end_lat and end_lng
for (i in seq_len(nrow(year22))) {
  #Check if the "end_lat" or "end_lng" values are NA for the current row
  if (is.na(year22$end_lat[i]) || is.na(year22$end_lng[i])) { 
    #Creation of a logical vector (match_row) indicating which rows in valid_stations have the same station name as the current row's "end_station_name".
    match_row <- valid_stations$start_station_name == year22$end_station_name[i]
    #if there is a match, the end_lat and end_lng in year22 values are replaced with the lat and lng values in         the valid_stations dataframe
    if (any(match_row)) {
      year22$end_lat[i] <- valid_stations$start_lat[match_row][1]
      year22$end_lng[i] <- valid_stations$start_lng[match_row][1]
    }
  }
}

# Identify row indices where the "end_lat" column has missing values (NA)
missing_end_lat_2 <- which(is.na(year22$end_lat))
# Identify row indices where the "end_lng" column has missing values (NA)
missing_end_lng_2 <- which(is.na(year22$end_lng))

# Display the structure of the "missing_end_lat_2" object to see the row indices
str(missing_end_lat_2)
# Display the structure of the "missing_end_lng_2" object to see the row indices
str(missing_end_lng_2)

#Calculate the distances between corresponding start and end points
year22$ride_distance <- distGeo(matrix(c(year22$start_lng, year22$start_lat), ncol=2), matrix (c(year22$end_lng, year22$end_lat), ncol=2))
#Convert to km
year22$ride_distance <- year22$ride_distance/1000

#Remove data entries where ride_length is negative or equal to 0
year22_clean <- year22[!(year22$ride_length <= 0),]

# Specify the columns with potential NA values
columns_with_na <- c("started_at", "ended_at", "start_lat", "start_lng", "end_lat", "end_lng", "start_time", "end_time", "ride_length", "ride_distance")

# Delete rows where all specified columns have NA values
year22_clean <- year22_clean[!(rowSums(is.na(year22_clean[, columns_with_na])) == length(columns_with_na)), ]



#ANALYZE PHASE

#Structure and summary of year22_clean
str(year22_clean)
summary(year22_clean)

#mean, median, max, and min for ride_length
year22_clean %>% 
  group_by(member_casual) %>%
  summarise(average_ride_length = mean(ride_length), median_ride_length = median(ride_length), 
            max_ride_length = max(ride_length), min_ride_length = min(ride_length))

# Calculate ride_count and ride_percentage
year22_clean_summary <- year22_clean %>%
  group_by(member_casual) %>%
  summarise(ride_count = n(), ride_percentage = (n() / nrow(year22_clean)) * 100)
# Display the summary table using kable
kable(year22_clean_summary, format = "html", caption = "Summary of ride_count and ride_percentage grouped by member_casual") %>%
  kable_styling(full_width = FALSE) # Adjust spacing

# Bar graph showing the total number of rides taken by each group of riders
ggplot(year22_clean_summary, aes(x = member_casual, y = ride_count, fill = member_casual)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = ride_count), position = position_stack(vjust = 0.5)) + 
  labs(x = "Casual Riders vs Members", y = "Number Of Rides", title = "Casual Riders vs Members Distribution")

#Pie chart of the percentage of rides taken by casual riders and by members
ggplot(year22_clean_summary, aes(x = "", y = ride_percentage, fill = member_casual)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(round(ride_percentage), "%")), position = position_stack(vjust = 0.5)) + 
  labs(title = "Percentage of rides taken by members and casual riders", x = NULL, y = NULL) +
  theme_void()

#Calculate mean, median, max, and min for each casual riders and for members
year22_clean %>%
  group_by(member_casual) %>% 
  summarise(average_ride_length = mean(ride_length), median_length = median(ride_length), 
            max_ride_length = max(ride_length), min_ride_length = min(ride_length))

#Order the days of the week
year22_clean$day_of_week <- ordered(year22_clean$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

#Calculates the number of rides and average duration per day of the week 
year22_clean %>% 
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(), average_ride_length = mean(ride_length),.groups="drop") %>% 
  arrange(member_casual, day_of_week)

#Visualization of the number of rides per day of the week
year22_clean %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(number_of_rides = n(), .groups="drop") %>% 
  arrange(member_casual, day_of_week) %>% 
  ggplot(aes(x = day_of_week, y = number_of_rides, fill = member_casual)) +
  labs(title ="Total Rides of Members and Casual Riders by Day of the Week (2022)", x = "Day of the Week", y = "Total Number of Rides") +
  geom_col(width=0.5, position = position_dodge(width=0.5)) 

#Visualization of the  average duration per day of the week
year22_clean %>%  
  group_by(member_casual, day_of_week) %>% 
  summarise(average_ride_length = mean(ride_length), .groups="drop") %>% 
  arrange(member_casual, day_of_week) %>% 
  ggplot(aes(x = day_of_week, y = average_ride_length, fill = member_casual)) +
  labs(title ="Average Ride Duration of Members and Casual Riders by Day of the Week (2022)", x = "Day of the Week", y = "Average Ride Duration in seconds") +
  geom_col(width=0.5, position = position_dodge(width=0.5))

# Order the months of the year.
year22_clean$month <- ordered(year22_clean$month, levels=c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))

#Calculates the number of rides and average duration per month
year22_clean %>% 
  group_by(member_casual, month) %>%  
  summarise(number_of_rides = n(), average_ride_length = mean(ride_length), .groups="drop") %>% 
  arrange(member_casual, month)

#Visualization of the number of rides and average duration per month
year22_clean %>%
  group_by(member_casual, month) %>%
  summarise(number_of_rides = n(), .groups="drop") %>%
  arrange(member_casual, month) %>% 
  ggplot(aes(x = month, y = number_of_rides, fill = member_casual)) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Total Rides of Members and Casual Riders Vs. Month (2022)", x = "Month", y = "Total Number of Rides") + 
  geom_col(width=0.5, position = position_dodge(width=0.5))

#Visualization of the average duration of rides for casual riders and member per month
year22_clean %>%
  group_by(member_casual, month) %>%
  summarise(average_ride_length = mean(ride_length), .groups="drop") %>%
  arrange(member_casual, month) %>% 
  ggplot(aes(x = month, y = average_ride_length, fill = member_casual)) +
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Average Duration of Rides of Members and Casual Riders Vs. Month (2022)", x = "Month", y = "Average Ride Duration in seconds") + 
  geom_col(width=0.5, position = position_dodge(width=0.5)) 

#Visualization of the average distance traveled by Members and Casual Riders per Month
year22_clean %>%
  group_by(member_casual, month) %>%
  summarise(average_ride_distance = mean(ride_distance), .groups="drop") %>%
  arrange(member_casual, month) %>%
  ggplot(aes(x = month, y = average_ride_distance, fill = member_casual)) + 
  theme(axis.text.x = element_text(angle = 45)) +
  labs(title = "Average distance traveled by Members and Casual Riders Vs. Month", x = "Month", y = "Average Ride Distance in Km.") +
  geom_col(width=0.5, position = position_dodge(width=0.5))

# Extract hour from start_time
year22_clean <- year22_clean %>%
  mutate(hour_of_day = hour(start_time))

# Create the plot
ggplot(year22_clean, aes(hour_of_day, fill = member_casual)) +
  geom_bar() +
  labs(title = "Cyclistic's Bike Demand per Hour of the Day by Day of the Week", x = "Hour of the day", y = "Total Number of Rides") +
  facet_wrap(~day_of_week, scales = "free")

#Calculate and visualize the total number of rides per rideable_type by casual riders and members
ride_counts <- year22_clean %>%
  group_by(rideable_type, member_casual) %>%
  summarise(count = n(), .groups = "drop")

ggplot(year22_clean, aes(rideable_type, fill = member_casual, .groups="drop" )) +
  geom_bar() + 
  geom_text(data = ride_counts, aes(label = count, y = count), position = position_stack(vjust = 0.5)) +
  labs(title = "Rideable Type Vs. Total Rides by Members and Casual Riders", x = "Rideable Type", y = "Total Number of Rides")

#Create a new data frame only for the most popular routes (routes with more than 75 rides)
coordinates_df <- year22_clean %>% 
  #filter out rows that have the same starting and ending station AND a ride length of under 5 minutes
  filter((start_lng != end_lng | start_lat != end_lat) & (ride_length < 300)) %>%
  group_by(start_lng, start_lat, end_lng, end_lat, member_casual, rideable_type) %>%
  summarise(total_rides = n(),.groups="drop") %>%
  filter(total_rides > 75)

#Create two different data frames depending on rider type (member_casual)
casual_riders <- coordinates_df %>% filter(member_casual == "casual")
member_riders <- coordinates_df %>% filter(member_casual == "member")

#The bounding box for Chicago was obtained using Google Maps
chicago <- c(left = -87.7530440694528, bottom = 41.669374586045535, right = -87.53573322225571, top = 41.99747022811183)
#Specify the bounding box of the map
map_of_chicago <- get_stamenmap(bbox = chicago, zoom = 13, maptype = "terrain")

#Casual Riders Map
ggmap(map_of_chicago, darken = c(0.1, "white")) +
  geom_point(casual_riders, mapping = aes(x = start_lng, y = start_lat, color = rideable_type), size = 1) +
  coord_fixed(0.8) +
  labs(title = "Most used routes by Casual riders",x = NULL, y = NULL) +
  theme()

#Members Map
ggmap(map_of_chicago, darken = c(0.1, "white")) +
  geom_point(member_riders, mapping = aes(x = start_lng, y = start_lat, color = rideable_type), size = 1) +  
  coord_fixed(0.8) +
  labs(title = "Most used routes by Member riders", x = NULL, y = NULL) +
  theme()
