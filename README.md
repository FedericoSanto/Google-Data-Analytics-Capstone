# Google Data Analytics Capstone


## Context
### About the company
In 2016, Cyclistic launched a successful bike-share offering. Since then, the program has grown to a fleet of 5,824 geotracked bicycles and locked into a network of 692 stations across Chicago. The bikes can be unlocked from one station and returned to
any other station in the system anytime. 
Until now, Cyclistic’s marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and
annual memberships.

## Opportunity
Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. Although the pricing flexibility helps Cyclistic attract more customers, they believe that maximizing the number of annual members will be key to
future growth. Rather than creating a marketing campaign that targets all new customers, they believe there is an excellent chance to convert casual riders into members, given that casual riders are already aware of the Cyclistic program and have
chosen Cyclistic for their mobility needs.

## Process
### Data Preparation
  - Data from 13 different months (September 2022 to September 2023) were imported using the read_csv function.
  - The datasets were checked for compatibility and merged into a single dataset (data_all) using rbind.
  - The dataset was examined for duplicate ride IDs, and none were found (anyDuplicated(data_all$ride_id)).
  - Unique categories for rideable_type and member_casual were identified: "electric_bike", "classic_bike", "docked_bike" and "casual", "member" respectively.

### Data Analysis
Here's a list of steps taken and questions that arose during the analysis:
  - Filter out rides shorter than or equal to 1 minute and longer than 600 minutes. Calculate summary statistics after filtering
  - It logical to have rides without start_station and end_station info (neither id or name)? 
    - Can bikes be picked up and left anywhere?
    - Does this happen in any group in particular?
  - Could we eliminate these entries and still have relevant data?
  - Create a grid of plots based on ride duration and member type.
    - The vast majority of data falls into the 0-100 group. How many rides would we exclude if we focus on this group?


**Ride Duration Distribution:**

  Rides with durations of less than 1 minute and over 10 hours were filtered out. The data was then analyzed for ride duration distribution.
  It was observed that 99.8% of rides were within 100 minutes.

  
**Start and End Station Information:**

  Rides with missing start and end station information were examined. 6.8% of rides had incomplete station details.
  This phenomenon was more prominent in the "electric_bike" group, affecting 44.4% of casual riders and 55.6% of annual members.


**Ride Duration by Member Type:**

  Ride duration distributions were visualized for both casual and annual members.
  It was noted that both groups had similar distributions with the majority of rides being within 20 minutes.
  
  <!--    
    ![Ride Duration by Member Type](plot_ride_duration_distribution_by_member_type.png)
    ![Ride Start Times by Member Type](plot_ride_start_times_by_member_type.png) 
  
  -->
<p align="center">
  <img align="center" src="plot_ride_duration_distribution_by_member_type.png" alt="Ride Duration by Member Type">
</br></br>
  
  <img align="center" src="plot_ride_start_times_by_member_type.png" alt="Ride Start Times by Member Type">
</p>
  <!--   
  <img align="right" src="plot_ride_start_times_by_member_type.png" alt="Ride Start Times by Member Type">  
  -->
  


  
#### Popular Routes:
  Routes were analyzed based on start and end stations to identify the most frequently used routes for casual and annual members.
  
  **Top Routes for Annual Members**
  
  - Ellis Ave & 60th St to University Ave & 57th St (6,401 rides)
  - Ellis Ave & 60th St to Ellis Ave & 55th St (6,138 rides)
  - University Ave & 57th St to Ellis Ave & 60th St (5,872 rides)

  
  **Top Routes for Casual Riders**
  
  - Streeter Dr & Grand Ave to Streeter Dr & Grand Ave (8,471 rides)
  - DuSable Lake Shore Dr & Monroe St to DuSable Lake Shore Dr & Monroe St (6,632 rides)
  - DuSable Lake Shore Dr & Monroe St to Streeter Dr & Grand Ave (5,275 rides)


**Top Starting Stations for Casual Riders**
![Top Starting Stations for Casual Riders](viz_geographical_05_casual_start.png)

**Top Ending Stations for Casual Riders**
![Top Ending Stations for Casual Riders](viz_geographical_05_casual_end.png)


Here's the [RStudio code](RStudio_code.r).





## Conclusions

In conclusion, the analysis underscores a compelling opportunity for Cyclistic to boost profitability by transitioning casual riders into annual members. The strategy involves implementing a targeted marketing campaign designed to showcase the benefits of membership, leveraging the existing awareness among casual riders.

**Recommended actions**

Strategic ad placement:
- Deploy printed ads strategically at high-traffic stations frequented by casual riders, based on the most popular routes:
  - Streeter Dr & Grand Ave to Streeter Dr & Grand Ave
  - DuSable Lake Shore Dr & Monroe St to DuSable Lake Shore Dr & Monroe St
  - DuSable Lake Shore Dr & Monroe St to Streeter Dr & Grand Ave

Incentivize morning rides:
- Recognizing the popularity of afternoon rides, offer morning discounts for casual riders. This approach aims to make membership more appealing during specific time slots.


**Measuring success**

The impact of the campaign will be tracked through:

- Changes in ridership during morning hours.
- Conversion rates of casual riders to annual members.

**Strategic flexibility**

The success metrics will serve as a compass for data-driven decision-making. This approach allows for ongoing assessment and adjustments to the campaign strategy, ensuring adaptability to changing dynamics.

This targeted marketing initiative aligns with Cyclistic's overarching goal of maximizing annual memberships for sustained and profitable growth.
