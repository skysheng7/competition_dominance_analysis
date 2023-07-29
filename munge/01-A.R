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
warning_days$date <- ymd(warning_days$date, tz="America/Los_Angeles")

################################################################################
############# Feeding & Drinking Analysis from Insentec Data ###################
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

# Colnames in the feed and water bin log files, change based on your own file format
coln=c("Transponder","Cow","Bin","Start","End","Duration","Startweight","Endweight","Comment","Intake","Intake2","X1","X2","X3","X4")
coln.wat=c("Transponder","Cow","Bin","Start","End","Duration","Startweight","Endweight","Intake")

#Check your bins of interest: Feed bins: 1-30, water bins:1-5 (all)
#Get the feeder, drinker and combined data into a list
len = length(fileNames.f)
all.fed=list()
all.wat=list()
all.comb=list()






