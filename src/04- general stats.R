###################################################################################################
###############################General stats about the data #######################################
###################################################################################################
# long duration
# visits longer than 30 minutes
minute_thereshold <- 30
second_thereshold <- minute_thereshold * 60
percent_longer_than30 <- nrow(master_feeding[which(master_feeding$Duration > second_thereshold),])/nrow(master_feeding)

data_summary_dur <- summary(master_feeding$Duration)
Q1_dur <-data_summary_dur[["1st Qu."]]
Q3_dur <-data_summary_dur[["3rd Qu."]]
IQR_dur <-Q3_dur - Q1_dur
upper_whisker_dur <-  Q3_dur+(1.5)*IQR_dur
lower_whisker_dur <-  Q1_dur-(1.5)*IQR_dur
dur_ourliter_percent <- nrow(master_feeding[which(master_feeding$Duration > upper_whisker_dur),])/nrow(master_feeding)

# large feed intake
data_summary_intake <- summary(master_feeding$Intake)
Q1_intake <-data_summary_intake[["1st Qu."]]
Q3_intake <-data_summary_intake[["3rd Qu."]]
IQR_intake <-Q3_intake - Q1_intake
upper_whisker_intake <-  Q3_intake+(1.5)*IQR_intake
lower_whisker_intake <-  Q1_intake-(1.5)*IQR_intake
intake_ourliter_percent <- nrow(master_feeding[which(master_feeding$Intake > upper_whisker_intake),])/nrow(master_feeding)

# double detections
load(here("data/results/double_detection_1cow_2bins.rda"))
for (i in 1:length(double_bin_detection_list)) {
  if (i == 1) {
    double_detection_master <- double_bin_detection_list[[i]]
  } else {
    double_detection_master <- rbind(double_detection_master, double_bin_detection_list[[i]])
  }
}
double_detection_percent <- nrow(double_detection_master)/nrow(master_feeding)


# calculate the average and SD of days each cow stayed in the trial
cow_day_cal <- unique(master_comb[, c("Cow", "date")])
cow_day_cal$count <- 1
cow_day_sum <- aggregate(cow_day_cal$count, by = list(cow_day_cal$Cow), FUN = sum)
colnames(cow_day_sum) <- c("Cow", "total_days")
cow_day_mean <- mean(cow_day_sum$total_days)
cow_day_sd <- sd(cow_day_sum$total_days)

### calculate the average time for morning feed delivery
load(here("data/results/feed_delivery.rda"))
time_interval_after_feed_added$date <- ymd(time_interval_after_feed_added$date, tz=time_zone)
master_feed_replacement_all$date <- ymd(master_feed_replacement_all$date, tz=time_zone)
time_interval_after_feed_added <- time_interval_after_feed_added[which(time_interval_after_feed_added$date %in% master_feed_replacement_all$date),]
# Filter rows with time between 4 am and 8 am
time_interval_after_feed_added_filtered <- time_interval_after_feed_added %>% filter(hour(morning_feed_add_start) >= 4 & hour(morning_feed_add_start) < 8)
# Extract the time part from morning_feed_add_start
time_interval_after_feed_added_filtered <- time_interval_after_feed_added_filtered %>% mutate(morning_time_part = as.numeric(format(morning_feed_add_start, format = "%H")) * 60 + as.numeric(format(morning_feed_add_start, format = "%M")))
# Calculate the average time in minutes
average_time <- mean(time_interval_after_feed_added_filtered$morning_time_part)
# Convert the average time to hours and minutes format
average_hh_mm_am <- sprintf("%02d:%02d", average_time %/% 60, round(average_time %% 60))
# Print the average time expressed in hh:mm
average_hh_mm_am

### calculate the average time for afternoon feed delivery
# Define the desired time range (e.g., 1 pm to 5 pm)
start_hour <- 13
end_hour <- 17
# Filter rows with time within the desired range
time_interval_after_feed_added_filtered <- time_interval_after_feed_added %>% filter(hour(afternoon_feed_add_start) >= start_hour & hour(afternoon_feed_add_start) < end_hour)
# Extract the time part from afternoon_feed_add_start
time_interval_after_feed_added_filtered <- time_interval_after_feed_added_filtered %>% mutate(afternoon_time_part = as.numeric(format(afternoon_feed_add_start, format = "%H")) * 60 + as.numeric(format(afternoon_feed_add_start, format = "%M")))
# Calculate the average time in minutes
average_time <- mean(time_interval_after_feed_added_filtered$afternoon_time_part)
# Convert the average time to hours and minutes format
average_hh_mm_pm <- sprintf("%02d:%02d", average_time %/% 60, round(average_time %% 60))
# Print the average time expressed in hh:mm
average_hh_mm_pm

# calculate the number of days included at each level
load(here("data/results/replacement_sampled_master.rda"))
unique_day_level <- unique(replacement_sampled_master[, c("date", "start_density", "end_density")])
unique_day_level$count <- 1
unique_day_sum <- aggregate(unique_day_level$count, by= list(unique_day_level$end_density), FUN = sum)
colnames(unique_day_sum) <- c("end_occupancy", "total_days")
