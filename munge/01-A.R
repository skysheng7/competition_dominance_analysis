###################################################################################################
######################################### TO BE DELETED ###########################################
###################################################################################################
library('ProjectTemplate')
load.project()

# Load all packages from library
library(lubridate)
library(plyr)
library(here)
#library(ggplot2)

################################################################################
###################### data loading & processing ###############################
################################################################################
###### Load feed and water file names
# set work directory and load data
input_dir <- here("data")
output_dir <- here("result")
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
# this part involves processing the data that is customized for this study only
# please change this based on your study
# process daylight saving dates dataframe and warning date data frame
daylight_saving_table <- daylight_saving_process(daylight_saving_csv)
warning_days$date <- ymd(warning_days$date, tz=time_zone)

################################################################################
##### Feeding & Drinking loading and initial processing from Insentec Data #####
################################################################################
# check if you have both water and feed data for each day
# we only retain the dates when both drinking and feeding data are available at
# the same time
date_compare <- compare_files(fileNames.f, fileNames.w)
fileNames.f <- date_compare$Feed_dir
fileNames.w <- date_compare$Drink_dir

# get date range for this dataset
date_result <- get_date_range(date_compare)
start_date <- date_result$start_date
end_date <- date_result$end_date
date_range <- date_result$date_range

# read in feed and water data into a list of dataframes
all.fed <- process_all_feed(fileNames.f, coln, cow_delete_list, feed_transponder_delete_list, min_feed_bin, max_feed_Bin, feed_coln_to_keep)
all.wat <- process_all_water(fileNames.w, coln.wat, cow_delete_list, wat_transponder_delete_list, min_wat_bin, max_wat_Bin, wat_coln_to_keep, bin_id_add)
all.comb <- combine_feeder_and_water_data(all.fed, all.wat)

# combine data frame different dates into 1 master dataframe
# Calling the function for each data list:
master_feeding <- merge_data(all.fed)
master_drinking <- merge_data(all.wat)
master_comb <- merge_data(all.comb)

################################################################################
############################## Quality Check ###################################
################################################################################
# generate an empty warning dataframe







