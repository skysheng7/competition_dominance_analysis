# Raw data files
If the data files are encoded in a supported file format (e.g., csv, dat), they'll automatically be loaded when you call `load.project()`.


## Dataset Specific Information for: `daylight_saving_csv.csv`
**Description:** This dataframe records the 2 dates when daylight saving changes happened in each year from 2000-2024

**Number of Variables:** 3  

**Number of Cases/Rows:** 25 

**Variable List:**
1. **Year:** The year of daylight saving dates record
2. **Spring:** The date when daylight saving changes happened in the spring
3. **Fall:** The date when daylight saving changes happened in the fall



## Dataset Specific Information for: `warning_days.csv`
**Description:** This dataframe records data from which dates should be deleted or treated with caution due to errors

**Number of Variables:** 3  

**Number of Cases/Rows:** 75  

**Variable List:**
1. **date:** the dates where data should be either deleted or treated with caution due to human disturbance or technical errors
2. **red_warning:** warnings saying those dates should be deleted and why
3. **orange_warning:** warnings saying those dates should betreated with caution or even deleted and why



## Dataset Specific Information for: `feed/VR******.DAT`
**Description:** raw data from electronic feeder using Insentec. File name has to be in the format of VR******.DAT, in y-m-d format. e.g., VR200715.DAT

**Number of Variables:** 15

**Number of Cases/Rows:** varies based on the day  

**Dataset Structure:** 309 files in total from 2020-07-15 to 2021-05-19

**Variable List:** *The .DAT file has no header. This is the sequence of columns that is intended after adding header*
1. **Transponder:** The transponder ID of the bin
2. **Cow:** cow ID
3. **Bin:** bin number
4. **Start:** start date and time
5. **End:** end date and time
6. **Duration:** total duration of this visit in seconds
7. **Startweight:** start weight (when the cow enters the bin) of the bin in kg
8. **Endweight:** end weight (when the cow leaves the bin) of the bin in kg
9. **Comment:** comments and notes
10. **Intake:** total feed intake Sstartweight - Endweight) of the visit in kg
11. **Intake2:** duplicated column of Intake. total feed intake Sstartweight - Endweight) of the visit in kg
12. **X1:** additional meaningless column
13. **X2:** additional meaningless column
14. **X3:** additional meaningless column
15. **X4:** additional meaningless column



## Dataset Specific Information for: `water/VW******.DAT` 
**Description:** raw data from electronic drinker using Insentec. File name has to be in the format of VW******.DAT, in y-m-d format. e.g., VW200715.DAT

**Number of Variables:** 9

**Number of Cases/Rows:** varies based on the day  

**Dataset Structure:** 309 files in total from 2020-07-15 to 2021-05-19

**Variable List:** *The .DAT file has no header. This is the sequence of columns that is intended after adding header*
"Transponder","Cow","Bin","Start","End","Duration","Startweight","Endweight","Intake"
1. **Transponder:** The transponder ID of the bin
2. **Cow:** cow ID
3. **Bin:** bin number
4. **Start:** start date and time
5. **End:** end date and time
6. **Duration:** total duration of this visit in seconds
7. **Startweight:** start weight (when the cow enters the bin) of the bin in kg
8. **Endweight:** end weight (when the cow leaves the bin) of the bin in kg
9. **Intake:** total water intake Sstartweight - Endweight) of the visit in kg



## Dataset Specific Information for: `results/double_bin_detection_list.rda`
**Description:** This dataset encapsulates information regarding cases where a cow's presence is detected simultaneously in two bins. Such occurrences can be indicative of potential sensor or data logging errors, specifically malfunctioning of certain Insentec bins. The dataset provides detailed insights on each detection instance, including the cow's ID, bin details, and associated timestamps.

**Number of Variables:** 10

**Number of Cases/Rows:** Varies based on the day and detection occurrences.

**Dataset Structure:** A list of data frames, where each data frame corresponds to a specific date. Each date might have multiple or no occurrences of double bin detections. 

**Variable List:** 
1. **Transponder:** The transponder ID of the bin.
2. **Cow:** Cow ID.
3. **Bin:** Bin number where the cow was detected.
4. **Start:** Start date and time of the detection.
5. **End:** End date and time of the detection.
6. **Duration:** Total duration of this detection instance in seconds.
7. **Startweight:** Start weight (when the cow is detected) of the bin in kg.
8. **Endweight:** End weight (post-detection) of the bin in kg.
9. **Intake:** Total water intake (Startweight - Endweight) during the detection in kg.
10. **Rate:** Intake rate, derived from the Intake and Duration.
**Note:** Given that for some dates, there might be no double bin detections, the associated data frame might have zero observations for that date.



## Dataset Specific Information for: `results/double_cow_detection_list.rda`
**Description:** This dataset captures instances where a bin registers 2 different cows at the same time, potentially indicating anomalies in the data logging process, and malfunctioning of certain Insentec bins. The dataset provides a structure to identify these occurrences based on dates

**Number of Variables:** 10

**Number of Cases/Rows:** Varies based on the day and detection occurrences.

**Dataset Structure:** A list of data frames, where each data frame corresponds to a specific date. Each date might have multiple or no occurrences of double cow detections. 

**Variable List:** same as `results/double_bin_detection_list.rda`



## Dataset Specific Information for: `results/negative_dur_list.rda`

**Description:** 
This dataset encompasses instances where visit duration is negative in certain Insentec bins, indicating potential errors in the data collection or logging process, and malfunctioning of certain Insentec bins. These instances can be critical for assessing the quality and integrity of the data. Each entry provides comprehensive details about the cow, the bin, and related timestamps.

**Number of Variables:** 
10

**Number of Cases/Rows:** 
Varies based on the day and the detected negative durations.

**Dataset Structure:** 
A list of data frames, with each data frame corresponding to a specific date. Each date might have multiple or no occurrences of negative durations. 

**Variable List:** same as `results/double_bin_detection_list.rda`



## Dataset Specific Information for: `results/negative_intake_list.rda`

**Description:**  
This dataset records instances where the feed or water bin visit has negative intake (only visits with more than 1 kg of negative intake. instances with < 1 kg of negative intake were omitted), suggesting potential discrepancies or errors in the data collection or logging mechanisms, and malfunctioning of certain Insentec bins. Comprehensive details about the cow, bin, and corresponding timestamps are provided for each instance.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the day and detected negative intakes.

**Dataset Structure:**  
The data is organized as a list of data frames. Each data frame corresponds to a specific date. Depending on the date, there may be multiple, or no recorded instances of negative intakes. 

**Variable List:** same as `results/double_bin_detection_list.rda`



## Dataset Specific Information for: `results/long_feed_dur_list.rda`

**Description:**  
This dataset encompasses instances where cows had prolonged durations (set at > 2000 seconds) at the feed bins. Extended feeding durations might indicate Insentec bin malfunctioning as it might have not recorded the cow leaving. The dataset offers granular details about the cows, their associated bins, and the timestamps corresponding to the beginning and end of their activity.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
Varies depending on the day and detected instances of prolonged feed durations.

**Dataset Structure:**  
The data is structured as a list of data frames. Each data frame represents data for a specific date. Depending on the day, there might be multiple, or no recorded instances of prolonged feed durations.

**Variable List:**  Same as `results/double_bin_detection_list.rda`.



## Dataset Specific Information for: `results/large_feed_intake_in_one_bout.rda`

**Description:**  
This dataset captures instances when cows have an unusually large feed intake (> 8 kg) in a single feeding bout. Such occurrences can signal malfunctioning of Insentec bins, and data collection errors. Detailed attributes of the cows, the bins they feed from, and the corresponding timestamps are presented for each instance.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
The count varies based on the day and instances of large feed intakes in a single bout.

**Dataset Structure:**  
The dataset is organized as a list of data frames. Each data frame represents information for a specific date. Depending on the particular day, there may be several or no recorded instances of large feed intakes in one bout.

**Variable List:** Same as `results/double_bin_detection_list.rda`.



## Dataset Specific Information for: `results/large_feed_intake_in_short_time.rda`

**Description:**  
This dataset captures instances when cows have a high feed intake in an unusually short duration (intake per visit > 5kg, and rate > 0.008 kg/s). These events can indicate malfunctioning of Insentec bins or potential data collection errors. Detailed attributes of the cows, the bins they feed from, and the corresponding timestamps are documented for each occurrence.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
The count varies based on the day.

**Dataset Structure:**  
The dataset is organized as a list of data frames. Each data frame provides data for a specific date. Depending on the particular day, there may be multiple or no recorded instances of large feed intakes in a short duration.

**Variable List:** Same as `results/double_bin_detection_list.rda`.



## Dataset Specific Information for: `results/long_wat_dur_list.rda`

**Description:**  
This dataset highlights instances where cows have a prolonged water intake duration (> 1800 seconds). Extended durations could be an indication of Insentec bin malfunction and data collection errors. Each record provides detailed attributes about the cows, the water bins they drank from, and the associated timestamps.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
The count changes based on the day and instances of prolonged water intake durations.

**Dataset Structure:**  
The dataset is systematized as a list of data frames, with each data frame detailing information for a particular date. Depending on the specific day, there might be several or no documented instances of long water intake durations.

**Variable List:** Same as `results/double_bin_detection_list.rda`.



## Dataset Specific Information for: `results/large_water_intake_in_one_bout.rda`

**Description:**  
This dataset records occurrences when cows have a high large water intake (> 30 kg) in a single bout. Such patterns could suggest potential issues with the Insentec bins or data collection anomalies. The dataset provides a comprehensive overview of the cows, the water bins they accessed, and the pertinent timestamps for each case.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
The count fluctuates based on the day and recorded instances of substantial water intakes in one bout.

**Dataset Structure:**  
Data is presented as a list of data frames, with each frame corresponding to a distinct date. Depending on the date in question, there may be multiple or no documented episodes of large water intakes in a single bout.

**Variable List:** Same as `results/double_bin_detection_list.rda`.



## Dataset Specific Information for: `results/large_water_intake_in_short_time.rda`

**Description:**  
This dataset identifies instances when cows exhibit a high water intake in an exceptionally short duration (intake per visit > 10 kg, and rate > 0.35 kg/s). Such events could hint at potential Insentec bin malfunctions or data collection errors. Detailed attributes of the cows, the water bins they used, and the related timestamps are enumerated for each incident.

**Number of Variables:**  
10

**Number of Cases/Rows:**  
The tally varies based on the day and occurrences of large water intakes in a short timeframe.

**Dataset Structure:**  
The dataset is framed as a list of data frames, with each one representing data for a specific date. Depending on the day in focus, there may be several or no recorded instances of rapid, large water intakes.

**Variable List:** Same as `results/double_bin_detection_list.rda`.



## Dataset Specific Information for: `results/bins_visit_num.rda`

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



## Dataset Specific Information for: `results/visit_per_bin_per_cow.rda`

**Description:**  
This dataset depicts the total number of times each cow visited each bins on a particular day. By isolating cow-bin interactions, we can assess individual cow behaviors and potentially pinpoint anomalies or consistant behaviors.

**Number of Variables:**  
3

**Number of Cases/Rows:**  
The count fluctuates based on the number of cows, the bins they visited, and the frequency of their visits for a specific day.

**Dataset Structure:**  
Organized as a list of data frames, each item in the list corresponds to a unique date. Every data frame lists out interactions of cows with bins for its respective day.

**Variable List:**
- **Cow**: Identifies the individual cow via its ID.
- **Bin**: Represents the bin ID the cow visited.
- **Visit_freq**: The total number of times a specific cow visited a particular bin on that day.



## Dataset Specific Information for: `results/bin_num_visit_per_cow.rda`

**Description:**  
This dataset presents a breakdown of the number of bins (categorized into feed and water) visited by each cow on a specified date. By understanding the distribution of bin visits, we can glean insights into individual cow habits or possibly detect unusual patterns.

**Number of Variables:**  
4

**Number of Cases/Rows:**  
This varies, depending on the number of cows in the dataset for the specific date.

**Dataset Structure:**  
The dataset is a list of data frames. Each list item corresponds to a unique date, and every data frame gives a summary of bin visits for each cow for that day.

**Variable List:**
- **Cow**: The ID of the cow.
- **num_of_feed_bins_visited**: Details the total number of feed bins a cow visited.
- **num_of_water_bins_visited**: Details the total number of water bins a cow visited.
- **total_num_of_bins_visit**: Offers the aggregated count of bins (feed + water) a cow visited.



## Dataset Specific Information for: `results/feed_delivery.rda`

**Description:**  
The dataset provides a structured overview of specific feed delivery times and intervals after the feed delivery. It is essential for tracking the feed delivery at different times of the day: morning, afternoon, and noon.

**Number of Variables:**  
16

**Number of Cases/Rows:**  
This can vary based on the dates available in the dataset.

**Dataset Structure:**  
The dataset is structured as a data frame. Each row corresponds to a unique date, and each column provides details about feed delivery and subsequent time intervals post delivery for that day.

**Variable List:**
- **date**: Date when the observation was made. It's in the POSIXct format.
  
- **morning_feed_add_start**: The exact time when the feed was added in the morning.

- **morning_90min_after_feed**: Time marking 90 minutes after the morning feed was added.
  
- **morning_2h_after_feed**: Time marking 2 hours post the morning feed addition.
  
- **morning_3h_after_feed**: Time marking 3 hours post the morning feed addition.
  
- **afternoon_feed_add_start**: The exact time when the feed was added in the afternoon.
  
- **afternoon_90min_after_feed**: Time marking 90 minutes after the afternoon feed was added.
  
- **afternoon_2h_after_feed**: Time marking 2 hours post the afternoon feed addition.
  
- **afternoon_3h_after_feed**: Time marking 3 hours post the afternoon feed addition.
  
- **morning_feed_delivery_no_found**: Character indicator if the morning feed delivery was not found. An empty string indicates that the delivery was found.
  
- **afternoon_feed_delivery_no_found**: Character indicator if the afternoon feed delivery was not found. An empty string indicates that the delivery was found.

- **noon_feed_add_start**: The exact time when the feed was added at noon.

- **noon_90min_after_feed**: Time marking 90 minutes post the noon feed addition.

- **noon_2h_after_feed**: Time marking 2 hours post the noon feed addition.

- **noon_3h_after_feed**: Time marking 3 hours post the noon feed addition.

- **noon_feed_delivery_found**: Character indicator if the noon feed delivery was found. An empty string indicates that the delivery was not found.

**Notes:** 
1. NA values in the dataset indicate that the data was not available or the event (like feed addition) did not occur.
2. Time variables are in POSIXct format, providing precise timestamp information, including date and time.
3. The variables ending with "_no_found" or "_found" provide indicators on whether feed was delivered or not during those specific times of the day.




## Dataset Specific Information for: `results/Insentec_warning.rda`

**Description:**  
This dataset contains warning logs and possible anomalies detected related to bin malfunctioning or cow abnormal feeding & drinking behaivours on specific dates.

**Number of Variables:**  
26

**Number of Cases/Rows:**  
317

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



## Dataset Specific Information for: `results/Cleaned_feeding_original_data.rda`

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



## Dataset Specific Information for: `results/Cleaned_drinking_original_data.rda`

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



## Dataset Specific Information for: `results/Cleaned_combined_original_data.rda`

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



## Dataset Specific Information for: `results/Insentec_final_summary`

**Description:**  
The `Insentec_final_summary` dataset provides a comprehensive overview of the feeding and drinking patterns of cows across different dates. Each row corresponds to individual observations detailing the feeding and drinking statistics (intake, duration, total number of visits, rate) of a particular cow on a given date.

**Number of Variables:**  
8

**Number of Cases/Rows:**  
147 observations.

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

