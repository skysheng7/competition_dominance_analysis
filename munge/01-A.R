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
daylight_saving_table <- daylight_saving_process(daylight_saving_table)
warning_days$date <- ymd(warning_days$date, tz="America/Los_Angeles")


################################################################################
############# Feeding & Drinking Analysis from Insentec Data ###################
################################################################################
# deal with when there are different number of feeding data files and drinking data files
# get a list of dates that has feeding information
feed_name <- data.frame(fileNames.f)
colnames(feed_name) <- c("Feed_dir")
feed_name$Feed_dir_mod <- trimws(feed_name$Feed_dir, which = "both")
feed_name$Feed_dir_mod <- chartr("/", "_", feed_name$Feed_dir_mod)
feed_name$Feed_dir_mod <- chartr(" ", "_", feed_name$Feed_dir_mod)
feed_name$Feed_dir_mod <- chartr(".", "_", feed_name$Feed_dir_mod)
feed_name$date <- ""
for (i in 1:nrow(feed_name)) {
  temp_list <- strsplit(feed_name$Feed_dir_mod[i], "_")  # split the filename string by "_"
  # extract date
  feed_name$date[i] = substring(temp_list[[1]][length(temp_list[[1]])-1], 3) # extract the date information of the file
}
# get a list of dates that has drinking information
wat_name <- data.frame(fileNames.w)
colnames(wat_name) <- c("Drink_dir")
wat_name$Drink_dir_mod <- trimws(wat_name$Drink_dir, which = "both")
wat_name$Drink_dir_mod <- chartr("/", "_", wat_name$Drink_dir_mod)
wat_name$Drink_dir_mod <- chartr(" ", "_", wat_name$Drink_dir_mod)
wat_name$Drink_dir_mod <- chartr(".", "_", wat_name$Drink_dir_mod)
wat_name$date <- ""
for (i in 1:nrow(wat_name)) {
  temp_list <- strsplit(wat_name$Drink_dir_mod[i], "_")  # split the filename string by "_"
  # extract date
  wat_name$date[i] = substring(temp_list[[1]][length(temp_list[[1]])-1], 3) # extract the date information of the file
}
# compare water and feeding sheet
compare_sheet <- merge(feed_name, wat_name, all = TRUE)
compare_sheet <- compare_sheet[order(compare_sheet$date),]
compare_sheet2 <- na.omit(compare_sheet)
fileNames.f <- compare_sheet2$Feed_dir
fileNames.w <- compare_sheet2$Drink_dir
# we only retain the dates when both drinking and feeding data are available at the same time





