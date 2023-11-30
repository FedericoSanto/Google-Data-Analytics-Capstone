# Packages and libraries
install.packages("tidyverse")
install.packages("dplyr")
install.packages("janitor")
install.packages("gridExtra")


library(tidyverse)
library(dplyr)
library(janitor)
library(gridExtra)


#-- Data import.
data_2022_09<-read_csv("202209-divvy-tripdata.csv")
data_2022_10<-read_csv("202210-divvy-tripdata.csv")
data_2022_11<-read_csv("202211-divvy-tripdata.csv")
data_2022_12<-read_csv("202212-divvy-tripdata.csv")
data_2023_01<-read_csv("202301-divvy-tripdata.csv")
data_2023_02<-read_csv("202302-divvy-tripdata.csv")
data_2023_03<-read_csv("202303-divvy-tripdata.csv")
data_2023_04<-read_csv("202304-divvy-tripdata.csv")
data_2023_05<-read_csv("202305-divvy-tripdata.csv")
data_2023_06<-read_csv("202306-divvy-tripdata.csv")
data_2023_07<-read_csv("202307-divvy-tripdata.csv")
data_2023_08<-read_csv("202308-divvy-tripdata.csv")
data_2023_09<-read_csv("202309-divvy-tripdata.csv")

#-- Check if they're row-bindable.
compare_df_cols_same(data_2022_09, data_2022_10, data_2022_11, data_2022_12, data_2023_01, data_2023_02, data_2023_03, data_2023_04, data_2023_05, data_2023_06, data_2023_07, data_2023_08, data_2023_09) 

#-- Merge into one dataset
data_all <- rbind(data_2022_09, data_2022_10, data_2022_11, data_2022_12, data_2023_01, data_2023_02, data_2023_03, data_2023_04, data_2023_05, data_2023_06, data_2023_07, data_2023_08, data_2023_09)

#-- Check if data makes sense after merging
dim(data_all)
str(data_all)
head(data_all)
tail(data_all)

#-- Data cleaning
anyDuplicated(data_all$ride_id) # 0
unique(data_all$rideable_type) # "electric_bike" "classic_bike"  "docked_bike" 
unique(data_all$member_casual) # "casual" "member"

#-- Data analysis 

  # Filter out rides with durations less than or equal to 1 minute and negative durations
  # Calculate ride duration in minutes
  data_all$ride_duration <- as.numeric(difftime(data_all$ended_at, data_all$started_at, units = "mins"))
  
  # Grouping rides by duration and counting the number of rides in each group
  ride_duration_groups <- filtered_data %>%
    group_by(ride_duration_group = cut(ride_duration, breaks = seq(0, 100000, by = 600))) %>% # 10 hours
    summarise(number_of_rides = n())
  
  # Viewing the grouped data
  print(ride_duration_groups) # 0.2007% rides are longer than 600 minutes (10 hours)
  
  # Filter out rides shorter than or equal to 1 minute and longer than 600 minutes
  filtered_data <- data_all[data_all$ride_duration > 1 & data_all$ride_duration <= 600, ]
  
  # Calculate summary statistics after filtering
  summary_stats <- filtered_data %>%
    group_by(member_casual) %>%
    summarise(
      mean_duration = mean(ride_duration, na.rm = TRUE),
      median_duration = median(ride_duration, na.rm = TRUE),
      min_duration = min(ride_duration, na.rm = TRUE),
      max_duration = max(ride_duration, na.rm = TRUE)
    )
  
  # Print summary statistics
  print(summary_stats)
  count(filtered_data) # 6,197,176


# Interesting questions:
  # - It logical to have rides without start_station and end_station info (neither id or name)? Can bikes be picked up and left anywhere?
    # ---- How often does this happen?
    blank_rows <- sum(is.na(filtered_data$start_station_name) & is.na(filtered_data$start_station_id) & is.na(filtered_data$end_station_name) & is.na(filtered_data$end_station_id))
    print(blank_rows) # 419,778 out of 6,197,176 (6,8%)
  
  # ---- Does this happen in any group in particular?
    # ---- ---- Group by rideable_type
    blank_rows <- filtered_data[is.na(filtered_data$start_station_name) & is.na(filtered_data$start_station_id) & is.na(filtered_data$end_station_name) & is.na(filtered_data$end_station_id),]
    grouped_data <- blank_rows %>%
      group_by(rideable_type) %>% # Group by rideable_type and summarize the count of each group
      summarise(count = n())
    
    print(grouped_data) # "electric_bike: 419,778". This happens only on the "electric_bike" group.
    
    # ---- ---- Group by member_casual
    blank_rows <- filtered_data[is.na(filtered_data$start_station_name) & is.na(filtered_data$start_station_id) & is.na(filtered_data$end_station_name) & is.na(filtered_data$end_station_id),]
    grouped_data <- blank_rows %>%
      group_by(member_casual) %>% # Group by member_casual and summarize the count of each group
      summarise(count = n())
    
    print(grouped_data) # casual: 186,512 (44.4%), member: 233,266 (55.6%).
    
    
    # ---- Could we eliminate these entries (blank_rows) and still have relevant data?
    # Let's compare data with and without these rows.
    
    # Create the two plots
    plot1 <- ggplot(data = filtered_data,
                    aes(x = ride_duration)) +
      geom_histogram(binwidth = 10, fill = "blue", alpha = 0.5) +
      labs(title = "Ride Duration Distribution (Including Blank Rows)",
           x = "Ride Duration (minutes)",
           y = "Frequency")
    
    plot2 <- ggplot(data = filtered_data[!is.na(filtered_data$start_station_name) & !is.na(filtered_data$start_station_id) & !is.na(filtered_data$end_station_name) & !is.na(filtered_data$end_station_id), ],
                    aes(x = ride_duration)) +
      geom_histogram(binwidth = 10, fill = "blue", alpha = 0.5) +
      labs(title = "Ride Duration Distribution (Excluding Blank Rows)",
           x = "Ride Duration (minutes)",
           y = "Frequency")
    
    # Arrange the plots side by side
    grid.arrange(plot1, plot2, ncol = 2)
    count(filtered_data) # 6,197,074
    count(blank_rows) # 419,776

# Remove blank_rows from filtered_data
filtered_data <- filtered_data[!(is.na(filtered_data$start_station_name) & is.na(filtered_data$start_station_id) & is.na(filtered_data$end_station_name) & is.na(filtered_data$end_station_id)), ]

# Check the updated count
count(filtered_data) #5,777,298

# Histogram of ride durations after removing blank_rows
ggplot(filtered_data, aes(x = ride_duration)) +
  geom_histogram(binwidth = 10, fill = "blue", alpha = 0.5) +
  labs(title = "Ride Duration Distribution (After Removing Blank Rows)",
       x = "Ride Duration (minutes)",
       y = "Frequency")


#-- Data analysis 
# Convert ride duration to a factor variable with custom breaks (every 100 minutes)
filtered_data$ride_duration_group <- cut(filtered_data$ride_duration, 
                                         breaks = seq(0, 600, by = 100), 
                                         labels = seq(0, 500, by = 100))

# Create a grid of plots based on ride duration and member type
ggplot(filtered_data, aes(x = ride_duration)) +
  geom_histogram(binwidth = 10, fill = "blue", alpha = 0.5) +
  labs(title = "Ride Duration Distribution",
       x = "Ride Duration (minutes)",
       y = "Frequency") +
  facet_grid(ride_duration_group ~ member_casual)

#The vast majority of data falls into the 0-100 group. How many rides would we exclude if we focus on this group?

# Counting rides in each group
ride_counts <- filtered_data %>%
  group_by(member_casual, ride_duration_group) %>%
  summarise(number_of_rides = n())

# Viewing the ride counts
print(ride_counts)
# We'd be leaving out about 1.98% of rides for casual riders and about 0.23% of rides for member riders. Seems reasonable.

count(filtered_data) #5,777,298

filtered_data <- filtered_data %>% 
  filter(ride_duration <= 100)

count(filtered_data) # 5,727,677

# Let's try the visualization again:
  # Convert ride duration to a factor variable with custom breaks (every 100 minutes)
  filtered_data$ride_duration_group <- cut(filtered_data$ride_duration, 
                                           breaks = seq(0, 600, by = 100), 
                                           labels = seq(0, 500, by = 100))
  
  # Create a grid of plots based on ride duration and member type
  ggplot(filtered_data, aes(x = ride_duration)) +
    geom_histogram(binwidth = 10, fill = "blue", alpha = 0.5) +
    labs(title = "Ride Duration Distribution",
         x = "Ride Duration (minutes)",
         y = "Frequency") +
    facet_grid(ride_duration_group ~ member_casual)
  
  #------------- v  Exported plot  v
  
  
  # Plotting the ride duration distributions
    ggplot(filtered_data, aes(x = ride_duration, fill = member_casual)) +
      geom_histogram(binwidth = 5, position = "identity", alpha = 0.5) +
      labs(title = "Ride Duration Distribution by Member Type",
           x = "Ride Duration (minutes)",
           y = "Frequency",
           fill = "Member Type") +
      scale_fill_manual(values = c("blue", "red")) +
      theme_minimal()
  
  
  # Popular routes
    # Group data by member type, start station, and end station
    route_counts <- filtered_data %>%
      group_by(member_casual, start_station_name, end_station_name) %>%
      summarise(number_of_rides = n())
    
    # Find the most popular routes for annual members
    top_routes_member <- route_counts %>%
      filter(member_casual == "member") %>%
      arrange(desc(number_of_rides)) %>%
      head(3)
    
    # Find the most popular routes for casual riders
    top_routes_casual <- route_counts %>%
      filter(member_casual == "casual") %>%
      arrange(desc(number_of_rides)) %>%
      head(3)
    
    # View the top routes for annual members and casual riders
    print("Top Routes for Annual Members:")
    print(top_routes_member)
    
    print("Top Routes for Casual Riders:")
    print(top_routes_casual)
    
      # Top Routes for Annual Members:
        # Ellis Ave & 60th St to University Ave & 57th St (6,401 rides)
        # Ellis Ave & 60th St to Ellis Ave & 55th St (6,138 rides)
        # University Ave & 57th St to Ellis Ave & 60th St (5,872 rides)
      
      # Top Routes for Casual Riders:
        # Streeter Dr & Grand Ave to Streeter Dr & Grand Ave (8,471 rides)
        # DuSable Lake Shore Dr & Monroe St to DuSable Lake Shore Dr & Monroe St (6,632 rides)
        # DuSable Lake Shore Dr & Monroe St to Streeter Dr & Grand Ave (5,275 rides)
    
  # Top Start and End Stations:
      top_routes_member <- filtered_data %>%
        filter(member_casual == "member") %>%
        group_by(start_station_name, start_station_id, end_station_name, end_station_id) %>%
        summarise(number_of_rides = n()) %>%
        arrange(desc(number_of_rides)) %>%
        head(3)
      
      top_routes_casual <- filtered_data %>%
        filter(member_casual == "casual") %>%
        group_by(start_station_name, start_station_id, end_station_name, end_station_id) %>%
        summarise(number_of_rides = n()) %>%
        arrange(desc(number_of_rides)) %>%
        head(3)
      
      print("Top Routes for Annual Members:")
      print(top_routes_member)
        # start_station_name       start_station_id   end_station_name         end_station_id      number_of_rides
        # 1 Ellis Ave & 60th St      KA1503000014     University Ave & 57th St KA1503000071              6401
        # 2 Ellis Ave & 60th St      KA1503000014     Ellis Ave & 55th St      KA1504000076              6138
        # 3 University Ave & 57th St KA1503000071     Ellis Ave & 60th St      KA1503000014              5872
      
      print("Top Routes for Casual Riders:")
      print(top_routes_casual)
        # start_station_name       start_station_id   end_station_name         end_station_id      number_of_rides
        # 1 Streeter Dr & Grand Ave           13022            Streeter Dr & Grand Ave           13022                     8471
        # 2 DuSable Lake Shore Dr & Monroe St 13300            DuSable Lake Shore Dr & Monroe St 13300                     6632
        # 3 DuSable Lake Shore Dr & Monroe St 13300            Streeter Dr & Grand Ave           13022                     5275
  
  # Ride duration by Member Type:
    # Create subsets for annual members and casual riders
    annual_members <- filtered_data %>% filter(member_casual == "member")
    casual_riders <- filtered_data %>% filter(member_casual == "casual")
    
    # Set up the layout for the plots
    par(mfrow=c(2,1))
    
    # Plot for annual members
    hist(as.POSIXlt(annual_members$started_at)$hour, breaks = seq(0, 24, by = 1), main = "Ride Start Times for Annual Members", xlab = "Hour of Day", ylab = "Frequency", col = "blue")
    
    # Plot for casual riders
    hist(as.POSIXlt(casual_riders$started_at)$hour, breaks = seq(0, 24, by = 1), main = "Ride Start Times for Casual Riders", xlab = "Hour of Day", ylab = "Frequency", col = "red")
    
      
    #------------- ^  Exported plot  ^
    
  # Ride Frequency by Member Type:
    ride_frequency <- filtered_data %>%
      group_by(member_casual) %>%
      summarise(total_rides = n())
    
    print(ride_frequency) #casual: 2,085,927, member: 3,641,750.
