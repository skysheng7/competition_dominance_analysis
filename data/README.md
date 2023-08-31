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

