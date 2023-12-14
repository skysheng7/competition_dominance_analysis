# Intermediate data files
Here stores some intermediate or important datasets generated during a preprocessing step. Any data set found in both the `cache` and `data` directories will be drawn from `cache` instead of `data` based on ProjectTemplate's priority rules.



## Dataset Specific Information for: `warning_days.RData` & `warning_days.hash`
**Description:** This dataframe records data from which dates should be deleted or treated with caution due to errors

**Number of Variables:** 3  

**Number of Cases/Rows:** 75  

**Variable List:**
1. **date:** the dates where data should be either deleted or treated with caution due to human disturbance or technical errors
2. **red_warning:** warnings saying those dates should be deleted and why
3. **orange_warning:** warnings saying those dates should betreated with caution or even deleted and why



## Dataset Specific Information for: `daylight_saving_csv.RData` & `daylight_saving_csv.hash`
**Description:** This dataframe records the 2 dates when daylight saving changes happened in each year from 2000-2024

**Number of Variables:** 3  

**Number of Cases/Rows:** 25 

**Variable List:**
1. **Year:** The year of daylight saving dates record
2. **Spring:** The date when daylight saving changes happened in the spring
3. **Fall:** The date when daylight saving changes happened in the fall



## Dataset Specific Information for: `Insentec_warning.RData` & `Insentec_warning.hash`

**Description:**  
This dataset contains warning logs and possible anomalies detected related to bin malfunctioning or cow abnormal feeding & drinking behaivours on specific dates.

**Number of Variables:**  
26

**Number of Cases/Rows:**  
306

**Dataset Structure:**  
The dataset is a data frame containing various observations and warnings related to cows' bin visits, such as double detections, missing cows, and unusual intake patterns.

**Variable List:**
1. **date**: The date of the observations (in POSIXct format).
2. **total_cow_number**: The total number of cows detected.
3. **missing_cow**: Yes or No, if there are cows missing (total number of cows < expected total number of cows in the pen)
4. **double_bin_detection_bin**: bin ID for the bins that are involved in double detections (the same cows being detected by 2 bins at the same time, the first bin is considered the malfunctioning bin as this is likely caused by the first bin did not register the cow leaving) 
5. **double_cow_detection_bin**: Information on bins that registers 2 cows at the same time
6. **negative_duration_bin**: Bins that registered a negative duration for a visit
7. **negative_intake_bin**: Bins that registered a negative intake value.
8. **no_show_after_6pm_cows**: Cows that did not visit any bin after 6 PM, indicative of losing ear tag
9. **no_show_after_12pm_cows**: Cows that did not visit any bin after 12 PM, indicative of losing ear tag
10. **no_visit_after_6pm_bins**: Bins that had no cow visits after 6 PM, indicative of bin malfunctioning
11. **no_visit_after_12pm_bins**: Bins that had no cow visits after 12 PM, indicative of bin malfunctioning
12. **bins_not_visited_today**: Bins that had no cow visits on the specified date, indicative of bin malfunctioning
13. **bins_with_low_visits_today**: Bins that had unusually low visits on the specified date, indicative of bin malfunctioning
14. **long_feed_duration_bin**: Bins that registers the same cow feeding for an unusually long duration, indicative of bin malfunctioning
15. **large_one_bout_feed_intake_bin**: Bins where a large intake was recorded in a single bout, indicative of bin malfunctioning
16. **large_feed_intake_in_short_time_bin**: Bins where a large feed intake was recorded in a short time span, indicative of bin malfunctioning
17. **cows_no_visit_to_feed_bin**: Cows that did not visit any feed bin, indicative of losing ear tag
18. **low_daily_feed_intake_cows**: Cows with low daily feed intake, indicative of abnormal status
19. **high_daily_feed_intake_cows**: Cows with high daily feed intake, indicative of abnormal status
20. **feed_add_time_no_found**: Instances where the time of adding feed was not found, indicative of no feed was added today
21. **long_water_duration_bin**: Bins that registers a cow drinking for an unusually long duration for water, indicative of bin malfunctioning
22. **large_one_bout_water_intake_bin**: Bins where a large water intake was recorded in a single bout, indicative of bin malfunctioning
23. **large_water_intake_in_short_time_bin**: Bins where a large water intake was recorded in a short time span, indicative of bin malfunctioning
24. **cows_no_visit_to_water_bin**: Cows that did not visit any water bin, indicative of losing ear tag or sickness
25. **low_daily_water_intake_cows**: Cows with low daily water intake, indicative of abnormal status
26. **high_daily_water_intake_cows**: Cows with high daily water intake, indicative of abnormal status




## Dataset Specific Information for: `all.feed2.RData` & `all.feed2.hash`

**Description:**  
This dataset contains cleaned individual feeding visit data of each cow to each bin on specific dates.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the date.

**Dataset Structure:**  
The dataset is a list of data frames. Each item in the list corresponds to a specific date and contains data related to feeding visit for that date.

**Variable List:**
1. **Transponder**: Unique ID of the transponder.
2. **Cow**: ID of the cow.
3. **Bin**: Bin ID the cow visited.
4. **Start**: Starting time of the visit (in POSIXct format).
5. **End**: Ending time of the visit (in POSIXct format).
6. **Duration**: Duration of the visit (in seconds).
7. **Startweight**: Weight of the feed at the start of the visit, in kg
8. **Endweight**: Weight of the feed at the end of the visit, in kg
9. **Intake**: Amount of feed intake (difference between start and end weights).
10. **rate**: Feeding rate of intake.



## Dataset Specific Information for: `all.wat2.RData` & `all.wat2.hash`

**Description:**  
This dataset contains cleaned original data related to the drinking visits of cows to different bins on specific dates.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the date

**Dataset Structure:**  
The dataset is a list of data frames. Each item in the list corresponds to a specific date and contains data related to drinking for that date.

**Variable List:**  
same as `results/Cleaned_feeding_original_data.rda`



## Dataset Specific Information for: `all.comb2.RData` & `all.comb2.hash`

**Description:**  
This dataset contains cleaned original data related to the drinking and feeding visits of cows to different bins on specific dates.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the date

**Dataset Structure:**  
The dataset is a list of data frames. Each item in the list corresponds to a specific date and contains data related to feeding and drinking combined for that date.

**Variable List:**  
same as `results/Cleaned_feeding_original_data.rda`




## Dataset Specific Information for: `master_feeding.RData` & `master_feeding.hash`

**Description:**  
This is a master dataframe contains cleaned individual feeding visit data of each cow to each bin on all dates

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the date.

**Variable List:**
1. **Transponder**: Unique ID of the transponder.
2. **Cow**: ID of the cow.
3. **Bin**: Bin ID the cow visited.
4. **Start**: Starting time of the visit (in POSIXct format).
5. **End**: Ending time of the visit (in POSIXct format).
6. **Duration**: Duration of the visit (in seconds).
7. **Startweight**: Weight of the feed at the start of the visit, in kg
8. **Endweight**: Weight of the feed at the end of the visit, in kg
9. **Intake**: Amount of feed intake (difference between start and end weights).
10. **rate**: Feeding rate of intake.



## Dataset Specific Information for: `master_drinking.RData` & `master_drinking.hash`

**Description:**  
This is a master dataframe contains cleaned original data related to the drinking visits of cows to different bins on all dates.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the date

**Variable List:**  
same as `master_feeding.RData` 



## Dataset Specific Information for: `master_comb.RData` & `master_comb.hash`

**Description:**  
This is a master dataframe containing cleaned original data related to the drinking and feeding visits of cows to different bins on all dates.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the date

**Variable List:**  
same as `master_feeding.RData` 




## Dataset Specific Information for: `Insentec_final_summary.RData` & `Insentec_final_summary.hash`

**Description:**  
The `Insentec_final_summary` dataset provides a comprehensive overview of the feeding and drinking patterns of cows across different dates. Each row corresponds to individual observations detailing the feeding and drinking statistics (intake, duration, total number of visits, rate) of a particular cow on a given date.

**Number of Variables:**  
8

**Number of Cases/Rows:**  
14680 observations.

**Dataset Structure:**  
The dataset is stored as a data frame. Each observation represents a cow's feeding & drinking statistics recorded on a specific date.

**Variable List:**

1. **date**: Date of observation. Format: YYYY-MM-DD.

2. **Cow**: Unique identifier for each cow.Data Type: Integer.

3. **Feeding_Intake(kg)**: The total amount of feed intake by the cow on the particular day, expressed in kg. Data Type: Numeric.

4. **Feeding_Duration(s)**: Total time the cow spent feeding on the specific day, recorded in seconds. Data Type: Numeric.

5. **Feeding_Visits**: Count of the cow's visits to the feeding area on the observed date. Data Type: Integer.

6. **Drinking_Intake(kg)**: The volume of water consumed by the cow on the day, denoted in kg.Data Type: Numeric.

7. **Drinking_Duration(s)**: Total time the cow spent drinking on the day, recorded in seconds.Data Type: Numeric.

8. **Drinking_Visits**: Count of the cow's visits to the drinking area on the observed date. Data Type: Integer.




## Dataset Specific Information for: `bins_visit_num.RData` & `bins_visit_num.hash`

**Description:**  
This dataset catalogs the frequency of total visits to each bin on a given day. Each bin ID, coupled with its respective visit count, offers a quick overview of bin utilization. Patterns in bin usage can assist in identifying potential problems or notable events in Insentec system.

**Number of Variables:**  
2

**Number of Cases/Rows:**  
The number changes depending on the day and the number of bins in operation.

**Dataset Structure:**  
This dataset is structured as a list of data frames. Each list item represents data corresponding to a specific date. Every data frame carries a count of visits for every bin for its respective day.

**Variable List:**
- **Bin**: Numerical values identifying the bin ID.
- **Visit_freq**: Indicates the total number of visits to the associated bin on that day.



## Dataset Specific Information for: `master_feed_replacement_all.RData` & `master_feed_replacement_all.hash`

**Description:**  
The dataset `master_feed_replacement_all` captures the replacement behaviours of cows at feed bins over an extended period. A replacement is defined by the time difference between one cow leaving the feed bin and the next cow entering being below a specific threshold (26s). It merges all the dataframe from the list in `results/Replacement_behaviour_by_date.rda` as 1 master dataframe

**Number of Variables:**  
6

**Number of Cases/Rows:**  
194,631

**Dataset Structure:**  
The dataset is structured as a data frame, where each row signifies an observed replacement.

**Variable List:**

1. **Reactor_cow**: The cow that was replaced. This is the cow that initially occupied the feed bin. Data Type: Integer.

2. **Bin**: Indicates the specific feed bin where the replacement occurred. Data Type: Numeric.

3. **Time**: Captures the exact timestamp of when the replacement took place. Data Type: POSIXct.

4. **date**: Represents the specific date of the observation. Data Type: Date.

5. **Actor_cow**: Refers to the cow that initiated the replacement action, pushing the `Reactor_cow` out and starting to feed from the bin. Data Type: Integer.

6. **Bout_interval**: Denotes the duration or time elapsed between the `Reactor_cow` leaving the bin and the `Actor_cow` entering the bin. It is essential to determine how promptly the replacement occurred. Data Type: Duration (from the `lubridate` package).



## Dataset Specific Information for: `master_steepness.RData` & `master_steepness.hash`
**Description:**  
The `master_steepness` dataset captures the Elo steepness under different feeder occupancies. It provides insights into the mean and standard deviation of the steepness for each resource occupancy level.

**Number of Variables:**  
3

**Number of Cases/Rows:**  
25

**Dataset Structure:**  
The dataset is structured as a data frame where each row represents a specific resource occupancy level, showing the mean and standard deviation of the Elo steepness for that level.

**Variable List:**

1. **resource_occupancy**: Represents the level of resource occupancy (feeder occupancy). It provides insights into the specific occupancy level for which the Elo steepness is calculated. Data Type: Numeric.

2. **steepness_mean**: The mean value of the Elo steepness for the respective resource occupancy level. This variable provides insights into the average steepness value for each occupancy level. Data Type: Numeric.

3. **steepness_SD**: The standard deviation of the Elo steepness for the respective resource occupancy level. This variable gives an understanding of the variability in the steepness values for each occupancy level. Data Type: Numeric.




## Dataset Specific Information for: `replacement_sampled_master.RData` & `replacement_sampled_master.hash`

**Note:** 
Due to data storage limit on gitHub, this data might not be available in the `results/replacement_sampled_master.rda`, but it would be in the `cache` folder: `cache/replacement_sampled_master.RData`

**Description:**  
The `replacement_sampled_master` dataset recorded replacements that got randomly sampled from all replacement events for the calculation of eloSteepness and dyadic analysis. It captures data related to the reactor cow, the bin, the time and date of the replacement, the actor cow, bout intervals, and various metrics related to bins and resource occupancy.

**Number of Variables:**  
19

**Number of Cases/Rows:**  
127,850

**Dataset Structure:**  
The dataset is structured as a grouped data frame where each row represents a unique replacement event.

**Variable List:**

1. **hour**: The hour during which the replacement occurred. Data Type: Integer.
2. **Reactor_cow**: Identifier for the reactor cow. Data Type: Numeric.
3. **Bin**: Bin number associated with the replacement. Data Type: Numeric.
4. **Time**: Exact time of the replacement. Data Type: POSIXct.
5. **date**: Date of the replacement. Data Type: Date.
6. **Actor_cow**: Identifier for the actor cow. Data Type: Numeric.
7. **Bout_interval**: Interval between the reactor cow leaving and the actor entering. Data Type: Duration (from lubridate package).
8. **total_bin**: Total number of bins. Data Type: Numeric.
9. **unoccupied_bin_with_feed**: Number of unoccupied bins with feed. Data Type: Numeric.
10. **unoccupied_empty_bin**: Number of unoccupied bins that are empty. Data Type: Numeric.
11. **occupied_total_bin**: Total number of occupied bins. Data Type: Numeric.
12. **resource_occupancy**: Proportion of resources occupied, also can be refered to as feeder occupancy. Data Type: Numeric.
13. **total_bin_with_feed**: Total number of bins with feed. Data Type: Numeric.
14. **occupied_bin_with_feed**: Number of occupied bins with feed. Data Type: Numeric.
15. **average_CD_10mon**: Average resource occupancy for that hour over 10 months. Data Type: Numeric.
16. **SD_of_CD_10mon**: Standard deviation of resource occupancy for that hour over 10 months. Data Type: Numeric.
17. **start_density**: each replacements happened in a range of resource occupancy (feeder occupancy), this refers to the minimum feeder occupancy in that range. Data Type: Numeric.
18. **end_density**: each replacements happened in a range of resource occupancy (feeder occupancy), this refers to the maximum feeder occupancy in that range. Data Type: Numeric.
19. **sampled**: Sampling indicator, 1 means this is randomly sampled, 0 means it is not. Data Type: Numeric.



## Dataset Specific Information for: `res_occupancy_seq.RData` & `res_occupancy_seq.hash`

**Description:**  
This is a numeric vector containing the cutoff point at each of the 25 levels of feeder occupancy

**Number of elements:**  
26




## Dataset Specific Information for: `sample_size.RData` & `sample_size.hash`

**Description:**  
This is a numeric variable recording how many replacements to sample from each of the 25 levels of feeder occupancy
