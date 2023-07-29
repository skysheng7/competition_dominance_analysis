###################################################################################################
######################################### TO BE DELETED ###########################################
###################################################################################################

# Load all packages from library
library(lubridate)
library(plyr)
library(ggplot2)

daylight_saving_table <- read.csv(here("data/daylight_saving_csv.csv"))


################################################################################
###################### data loading & processing ###############################
################################################################################
# set work directory and load data
input_dir <- here("data")
output_dir <- here("result")

# process daylight saving dates dataframe
daylight_saving_table <- daylight_saving_process(daylight_saving_table)

# load in feed and water data
fileNames.f <- list.files(path = here("data/feed_test"),full.names = TRUE,
                          recursive = TRUE,pattern =".DAT")
fileNames.w <- list.files(path = here("data/water_test"),full.names = TRUE,
                          recursive = TRUE,pattern =".DAT")
fileNames.f <- sort(fileNames.f)
fileNames.w <- sort(fileNames.w)

################################################################################
############# customized processing for this study (hard-coded) ################
################################################################################
# 
date <- c("2021-02-03", "2021-02-04", "2021-02-05", "2021-02-06", "2021-02-07", 
          "2021-02-08", "2021-02-09", "2021-02-10", "2021-03-06", "2021-03-11", 
          "2021-03-13", "2021-03-17", "2021-03-22",  "2021-04-27", "2021-04-28", 
          "2021-05-02", "2021-05-03")
Red_warning <- c("Human present disturbance", "Human present disturbance", 
                 "Insentec break down", "Insentec break down", 
                 "Insentec break down", "bin 5 & 6 down", "bin 5 & 6 down", 
                 "bin 3, 4, 5 & 6 down", 
                 "Insentec compressor was not working, and Cow 6062 lost 
                 transponder before 8AM", "Insentec disturbed in the morning", 
                 "Insentec aren't opening for cows, manually turned to all 
                 open in the morning", "Water bin broken down", 
                 "Insentec compressor down", 
                 "Feed composition change, no feed access during night", 
                 "Feed composition change, no feed access during night", 
                 "Missing data for half a day", "Missing data for half a day")
days_to_be_discarded <- data.frame(date, Red_warning)
days_to_be_discarded$date <- ymd(days_to_be_discarded$date, tz="America/Los_Angeles")

orange_date <- c("2021-02-11", "2021-02-12", "2021-02-16", "2021-02-17", 
                 "2021-02-18", "2021-03-16", "2021-03-23", "2021-04-08", 
                 "2021-04-09", "2021-04-10", "2021-04-11", "2021-04-15", 
                 "2021-05-06", "2021-05-07", "2021-05-08", "2021-05-09", 
                 "2021-05-10", "2021-05-11", "2021-05-12", "2021-05-13", 
                 "2021-05-17", "2021-06-27", "2021-06-28", "2021-06-29", 
                 "2021-06-30")
orange_warning <- c("Power Outage from 17:30 - 18:20; extreme cold weather", 
                    "extreme cold weather, bins not closing properly", 
                    "Cow 5120 lost both tages, registered as 1111",
                    "Cow 5120 lost both tages, registered as 1111", 
                    "Morning only:Cow 5120 lost both tages, registered as 1111", 
                    "No access to feed for several hours in the afternoon due to
                    hoof trimming", "Compressor down again", 
                    "cow 7064 was switched to 0", "cow 7064 was switched to 0", 
                    "cow 5096 was removed for half a day due to difficulty 
                    turning around in the parlor", "cow 5096 was removed for 
                    half a day due to difficulty turning around in the parlor", 
                    "Brush crew people were in the pen for significnat amount of 
                    time", "water bin 104 was temperorily closed", "water bin 
                    104 was temperorily closed", 
                    "water bin 104 was temperorily closed", 
                    "water bin 104 was temperorily closed", 
                    "water bin 104 was temperorily closed", 
                    "water bin 104 was temperorily closed", 
                    "water bin 104 was temperorily closed", 
                    "water bin 104 was temperorily closed", 
                    "Cows escaped to the pasture from around 9pm to 10:30 pm; 
                    bin 9 left closed for some part of the day", 
                    "Water bins kept all open starting 5:00PM due to heat wave",
                    "Water bins kept all open due to heat wave", 
                    "Water bins kept all open due to heat wave", 
                    "Water bins kept all open due to heat wave")
orange_date_sheet <- data.frame(orange_date, orange_warning)
colnames(orange_date_sheet) <- c("date", "orange_warning")
orange_date_sheet$date <- ymd(orange_date_sheet$date, tz="America/Los_Angeles")

warning_days <- merge(days_to_be_discarded, orange_date_sheet, all = TRUE)
warning_days[is.na(warning_days)] <- ""






