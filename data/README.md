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

## Dataset Specific Information for: `feed/VR******.DAT` 309 files in total from 2020-07-15 to 2021-05-19
**Description:** raw data from electronic feeder using Insentec. File name has to be in the format of VR******.DAT, in y-m-d format. e.g., VR200715.DAT
**Number of Variables:** 15
**Number of Cases/Rows:** varies based on the day  
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

## Dataset Specific Information for: `water/VW******.DAT` 309 files in total from 2020-07-15 to 2021-05-19
**Description:** raw data from electronic drinker using Insentec. File name has to be in the format of VW******.DAT, in y-m-d format. e.g., VW200715.DAT
**Number of Variables:** 9
**Number of Cases/Rows:** varies based on the day  
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
**Description:**This dataset encapsulates information regarding cases where a cow's presence is detected simultaneously in two bins. Such occurrences can be indicative of potential sensor or data logging errors. The dataset provides detailed insights on each detection instance, including the cow's ID, bin details, and associated timestamps.
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
**Usage Recommendations:**  The presence of double cow detections can be indicative of anomalies or errors in the Insentec bins.

## Dataset Specific Information for: `results/double_cow_detection_list.rda`
**Description:** This dataset captures instances where a bin registers 2 different cows at the same time, potentially indicating discrepancies or anomalies in the data logging process. The dataset provides a structure to identify these occurrences based on dates
**Number of Variables:** 10
**Number of Cases/Rows:** Varies based on the day and detection occurrences.
**Dataset Structure:** A list of data frames, where each data frame corresponds to a specific date. Each date might have multiple or no occurrences of double cow detections. 
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
**Note:** Given that for some dates, there might be no double cow detections, the associated data frame might have zero observations for that date.
**Usage Recommendations:** The presence of double cow detections can be indicative of anomalies or errors in the Insentec bins.

## Dataset Specific Information for: `results/negative_dur_list.rda`
